// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "./Bytes64Lib.sol";

contract Streebog {
    using Bytes64Lib for bytes;

    event log(string);
    event logs(bytes);
    event log_uint(uint);

    uint constant BLOCK_SIZE = 64;

    enum DigestSize {
        _256,
        _512
    }

    struct Context {
        bytes buffer;
        bytes hash;
        //
        bytes h;
        bytes N;
        bytes Sigma;
        //
        uint bufSize;
        DigestSize digestSize;
    }

    function initContext(DigestSize digestSize) internal pure returns (Context memory) {
        // only 256bit hash is supported
        assert(digestSize == DigestSize._256);

        Context memory ctx = Context({
            buffer: new bytes(BLOCK_SIZE),
            hash: new bytes(BLOCK_SIZE),
            h: new bytes(BLOCK_SIZE),
            N: new bytes(BLOCK_SIZE),
            Sigma: new bytes(BLOCK_SIZE),
            bufSize: 0,
            digestSize: digestSize
        });

        // In 256bit hashing `h` field is initialized with 0x01
        ctx.h.initWith01();

        return ctx;
    }

    function update(
        Context memory ctx,
        bytes memory data
    ) internal pure {
        uint chunkSize = 0;
        uint dataOffset = 0;
        uint len = data.length;

        // this is useful if message has already been updated
        if (ctx.bufSize > 0) {
            chunkSize = 64 - ctx.bufSize;
            if (chunkSize > len) {
                chunkSize = len;
            }

            ctx.buffer.copy(data, chunkSize, ctx.bufSize, dataOffset);

            ctx.bufSize += chunkSize;
            len -= chunkSize;
            dataOffset += chunkSize;

            if (ctx.bufSize == 64) {
                stage2(ctx, ctx.buffer, 0);
                ctx.bufSize = 0;
            }
        }

        while (len > 63) {
            stage2(ctx, data, dataOffset);
            dataOffset += 64;
            len -= 64;
        }

        if (len > 0) {
            ctx.buffer.copy(data, len, 0, dataOffset);
            ctx.bufSize = len;
        }
    }

    function final_(Context memory ctx) internal pure returns (bytes memory) {
        stage3(ctx);

        ctx.bufSize = 0;

        bytes memory digest;

        if (ctx.digestSize == DigestSize._256) {
            digest = new bytes(32);
            digest.copy(ctx.hash, 32, 0, 32);
        } else {
            digest = new bytes(64);
            digest.copy(ctx.hash, 64);
        }

        return digest;
    }

        function stage2(
        Context memory ctx,
        bytes memory data,
        uint dataOffset
    ) internal pure {
        bytes memory m = new bytes(BLOCK_SIZE);
        m.copy(data, m.length, 0 ,dataOffset);

        g(ctx.h, ctx.N, m);

        ctx.N.add512(ctx.N, getBuffer512());
        ctx.Sigma.add512(ctx.Sigma, m);
    }


    function stage3(Context memory ctx) internal pure {
        bytes memory buf = new bytes(64);

        // @todo double check __GOST3411_BIG_ENDIAN__
        buf[0] = bytes1(uint8(ctx.bufSize << 3));

        pad(ctx);

        g(ctx.h, ctx.N, ctx.buffer);

        ctx.N.add512(ctx.N, buf);
        ctx.Sigma.add512(ctx.Sigma, ctx.buffer);

        bytes memory buffer0 = getBuffer0();
        g(ctx.h, buffer0, ctx.N);

        g(ctx.h, buffer0, ctx.Sigma);

        ctx.hash.copy(ctx.h, BLOCK_SIZE);
    }

    function g(bytes memory h, bytes memory N, bytes memory m) internal pure {
        bytes memory data = new bytes(BLOCK_SIZE);
        bytes memory Ki = new bytes(BLOCK_SIZE);

        Ki.xor512(N, h);

        S(Ki);
        P(Ki);
        L(Ki);

        E(Ki, m, data);

        data.xor512(data, h);
        h.xor512(data, m);
    }

    function pad(Context memory ctx) internal pure {
        if (ctx.bufSize > 63) return;

        ctx.buffer.copy(getBuffer0(), ctx.buffer.length - ctx.bufSize, ctx.bufSize, 0);

        ctx.buffer[ctx.bufSize] = 0x01;
    }

    function getBuffer512() internal pure returns (bytes memory) {
        return (
            hex"0002000000000000000000000000000000000000000000000000000000000000"
            hex"0000000000000000000000000000000000000000000000000000000000000000"
        );
    }

    function getBuffer0() internal pure returns (bytes memory) {
        return  (
            hex"0000000000000000000000000000000000000000000000000000000000000000"
            hex"0000000000000000000000000000000000000000000000000000000000000000"
        );
    }


    function hash256_2(bytes calldata message) external pure returns(bytes memory) {
        Context memory ctx = initContext(DigestSize._256);
        update(ctx, message);
        return final_(ctx);
    }

    function hash256(
        bytes calldata message
    ) external pure returns (bytes memory) {
        bytes memory IV = new bytes(BLOCK_SIZE);

        IV.initWith01();

        bytes memory out = new bytes(32);
        out.copy(hash_X(IV, message), 32, 0, 32);
        return out;
    }

    function hash_X(
        bytes memory IV,
        bytes memory message
    ) internal pure returns (bytes memory) {
        (
            bytes memory v512,
            bytes memory v0,
            bytes memory Sigma,
            bytes memory N
        ) = getContext();
        bytes memory m = new bytes(BLOCK_SIZE);
        bytes memory hash = IV;

        uint len = message.length;

        // Stage 2
        while (len >= 512) {
            m.copy(message, 64, 0, len / 8 - 63 - ((len & 0x7) == 0 ? 1 : 0));

            g_N(N, hash, m);
            N.add512(N, v512);
            Sigma.add512(Sigma, m);
            len -= 512;
        }

        for (uint i = 0; i < BLOCK_SIZE; i++) {
            m[i] = 0x00;
        }

        for (uint i = 0; i < len / 8 + 1 - ((len & 0x7) == 0 ? 1 : 0); i++) {
            uint copyOffset = 63 - len / 8 + ((len & 0x7) == 0 ? 1 : 0);
            m[copyOffset + i] = bytes1(uint8(message[i]));
        }

        // Stage 3
        m[63 - len / 8] |= bytes1(uint8((1 << (len & 0x7))));

        g_N(N, hash, m);
        v512[63] = bytes1(uint8(len & 0xFF));
        v512[62] = bytes1(uint8(len >> 8));
        N.add512(N, v512);

        Sigma.add512(Sigma, m);

        g_N(v0, hash, N);
        g_N(v0, hash, Sigma);

        bytes memory out = new bytes(BLOCK_SIZE);
        out.copy(hash, BLOCK_SIZE);

        return out;
    }

    function g_N(bytes memory N, bytes memory h, bytes memory m) internal pure {
        bytes memory t = new bytes(BLOCK_SIZE);
        bytes memory K = new bytes(BLOCK_SIZE);

        K.xor512(N, h);

        S(K);
        P(K);
        L(K);

        E(K, m, t);

        t.xor512(t, h);
        h.xor512(t, m);
    }

    function E(
        bytes memory K,
        bytes memory m,
        bytes memory state
    ) internal pure {
        // ? what
        // memcpy(K, K, 64);

        state.xor512(m, K);

        for (uint i = 0; i < 12; i++) {
            S(state);
            P(state);
            L(state);
            KeySchedule(K, i);
            state.xor512(state, K);
        }
    }

    function KeySchedule(bytes memory K, uint i) internal pure {
        bytes memory C = getC(i);
        K.xor512(K, C);

        S(K);
        P(K);
        L(K);
    }

    function L(bytes memory state) internal pure {
        // Matrix A for MixColumns (L) function
        // prettier-ignore
        uint64[64] memory A = [
            0x8e20faa72ba0b470, 0x47107ddd9b505a38, 0xad08b0e0c3282d1c, 0xd8045870ef14980e,
            0x6c022c38f90a4c07, 0x3601161cf205268d, 0x1b8e0b0e798c13c8, 0x83478b07b2468764,
            0xa011d380818e8f40, 0x5086e740ce47c920, 0x2843fd2067adea10, 0x14aff010bdd87508,
            0x0ad97808d06cb404, 0x05e23c0468365a02, 0x8c711e02341b2d01, 0x46b60f011a83988e,
            0x90dab52a387ae76f, 0x486dd4151c3dfdb9, 0x24b86a840e90f0d2, 0x125c354207487869,
            0x092e94218d243cba, 0x8a174a9ec8121e5d, 0x4585254f64090fa0, 0xaccc9ca9328a8950,
            0x9d4df05d5f661451, 0xc0a878a0a1330aa6, 0x60543c50de970553, 0x302a1e286fc58ca7,
            0x18150f14b9ec46dd, 0x0c84890ad27623e0, 0x0642ca05693b9f70, 0x0321658cba93c138,
            0x86275df09ce8aaa8, 0x439da0784e745554, 0xafc0503c273aa42a, 0xd960281e9d1d5215,
            0xe230140fc0802984, 0x71180a8960409a42, 0xb60c05ca30204d21, 0x5b068c651810a89e,
            0x456c34887a3805b9, 0xac361a443d1c8cd2, 0x561b0d22900e4669, 0x2b838811480723ba,
            0x9bcf4486248d9f5d, 0xc3e9224312c8c1a0, 0xeffa11af0964ee50, 0xf97d86d98a327728,
            0xe4fa2054a80b329c, 0x727d102a548b194e, 0x39b008152acb8227, 0x9258048415eb419d,
            0x492c024284fbaec0, 0xaa16012142f35760, 0x550b8e9e21f7a530, 0xa48b474f9ef5dc18,
            0x70a6a56e2440598e, 0x3853dc371220a247, 0x1ca76e95091051ad, 0x0edd37c48a08a6d8,
            0x07e095624504536c, 0x8d70c431ac02a736, 0xc83862965601dd1b, 0x641c314b2b8ee083
        ];

        uint64 v = 0;

        /*
         * subvectors of 512-bit vector (64*8 bits)
         * an subvector is start at [j*8], its componenst placed
         * with step of 8 bytes (due to this function is composition
         * of P and L) and have length of 64 bits (8*8 bits)
         */
        for (uint i = 0; i < 8; i++) {
            v = 0;
            /*
             * 8-bit components of 64-bit subvectors
             * components is placed at [j*8+i]
             */
            for (uint k = 0; k < 8; k++) {
                /* bit index of current 8-bit component */
                for (uint j = 0; j < 8; j++) {
                    /* check if current bit is set */
                    if ((uint8(state[i * 8 + k]) & (1 << (7 - j))) != 0) {
                        v ^= A[k * 8 + j];
                    }
                }
            }
            for (uint k = 0; k < 8; k++) {
                // state[i*8+k] = (v & ((unsigned long long)0xFF << (7-k)*8)) >> (7-k)*8;
                uint64 tmp = (v & (uint64(0xFF) << ((7 - k) * 8))) >>
                    ((7 - k) * 8);
                state[i * 8 + k] = bytes1(uint8(tmp));
            }
        }
    }

    function P(bytes memory vect) internal pure {
        // Substitution for Transposition (P) function
        // prettier-ignore
        uint8[BLOCK_SIZE] memory Tau = [
            0,  8, 16, 24, 32, 40, 48, 56,
            1,  9, 17, 25, 33, 41, 49, 57,
            2, 10, 18, 26, 34, 42, 50, 58,
            3, 11, 19, 27, 35, 43, 51, 59,
            4, 12, 20, 28, 36, 44, 52, 60,
            5, 13, 21, 29, 37, 45, 53, 61,
            6, 14, 22, 30, 38, 46, 54, 62,
            7, 15, 23, 31, 39, 47, 55, 63
        ];

        bytes memory t = new bytes(64);

        for (uint i = 0; i < BLOCK_SIZE; i++) {
            t[i] = vect[Tau[i]];
        }

        vect.copy(t, BLOCK_SIZE);
    }

    function S(bytes memory vect) internal pure {
        // Substitution for SubBytes function
        // prettier-ignore
        bytes memory sbox = hex"fc_ee_dd_11_cf_6e_31_16_fb_c4_fa_da_23_c5_04_4d"
            hex"e9_77_f0_db_93_2e_99_ba_17_36_f1_bb_14_cd_5f_c1"
            hex"f9_18_65_5a_e2_5c_ef_21_81_1c_3c_42_8b_01_8e_4f"
            hex"05_84_02_ae_e3_6a_8f_a0_06_0b_ed_98_7f_d4_d3_1f"
            hex"eb_34_2c_51_ea_c8_48_ab_f2_2a_68_a2_fd_3a_ce_cc"
            hex"b5_70_0e_56_08_0c_76_12_bf_72_13_47_9c_b7_5d_87"
            hex"15_a1_96_29_10_7b_9a_c7_f3_91_78_6f_9d_9e_b2_b1"
            hex"32_75_19_3d_ff_35_8a_7e_6d_54_c6_80_c3_bd_0d_57"
            hex"df_f5_24_a9_3e_a8_43_c9_d7_79_d6_f6_7c_22_b9_03"
            hex"e0_0f_ec_de_7a_94_b0_bc_dc_e8_28_50_4e_33_0a_4a"
            hex"a7_97_60_73_1e_00_62_44_1a_b8_38_82_64_9f_26_41"
            hex"ad_45_46_92_27_5e_55_2f_8c_a3_a5_7d_69_d5_95_3b"
            hex"07_58_b3_40_86_ac_1d_f7_30_37_6b_e4_88_d9_e7_89"
            hex"e1_1b_83_49_4c_3f_f8_fe_8d_53_aa_90_ca_d8_85_61"
            hex"20_71_67_a4_2d_2b_09_5b_cb_9b_25_d0_be_e5_6c_52"
            hex"59_a6_74_d2_e6_f4_b4_c0_d1_66_af_c2_39_4b_63_b6"
            ;

        for (uint i = 0; i < BLOCK_SIZE; i++) {
            vect[i] = sbox[uint8(vect[i])];
        }
    }

    function getContext()
        internal
        pure
        returns (bytes memory, bytes memory, bytes memory, bytes memory)
    {
        // Dynamic bytes arrays are zero initialized by default
        bytes memory v512 = new bytes(BLOCK_SIZE);
        // @todo clarify the reason for this
        v512[62] = 0x02;

        bytes memory v0 = new bytes(BLOCK_SIZE);
        bytes memory Sigma = new bytes(BLOCK_SIZE);
        bytes memory N = new bytes(BLOCK_SIZE);
        return (v512, v0, Sigma, N);
    }

    function getC(uint i) internal pure returns (bytes memory) {
        // Constant values for KeySchedule function
        // prettier-ignore
        bytes memory C;
        if (i == 0) {
            C = bytes(
                hex"b1085bda1ecadae9ebcb2f81c0657c1f"
                hex"2f6a76432e45d016714eb88d7585c4fc"
                hex"4b7ce09192676901a2422a08a460d315"
                hex"05767436cc744d23dd806559f2a64507"
            );
        } else if ( i ==1 ) {

            C= bytes(
                hex"6fa3b58aa99d2f1a4fe39d460f70b5d7"
                hex"f3feea720a232b9861d55e0f16b50131"
                hex"9ab5176b12d699585cb561c2db0aa7ca"
                hex"55dda21bd7cbcd56e679047021b19bb7"
            );
        }
            else if (i == 2) {

            C= bytes(
                hex"f574dcac2bce2fc70a39fc286a3d8435"
                hex"06f15e5f529c1f8bf2ea7514b1297b7b"
                hex"d3e20fe490359eb1c1c93a376062db09"
                hex"c2b6f443867adb31991e96f50aba0ab2"
            );
            }
             else if (i==3) {

            C= bytes(
                hex"ef1fdfb3e81566d2f948e1a05d71e4dd"
                hex"488e857e335c3c7d9d721cad685e353f"
                hex"a9d72c82ed03d675d8b71333935203be"
                hex"3453eaa193e837f1220cbebc84e3d12e"
            );
             }
             else if (i == 4)
            C= bytes(
                hex"4bea6bacad4747999a3f410c6ca92363"
                hex"7f151c1f1686104a359e35d7800fffbd"
                hex"bfcd1747253af5a3dfff00b723271a16"
                hex"7a56a27ea9ea63f5601758fd7c6cfe57"
            ); else if (i==5)
            C= bytes(
                hex"ae4faeae1d3ad3d96fa4c33b7a3039c0"
                hex"2d66c4f95142a46c187f9ab49af08ec6"
                hex"cffaa6b71c9ab7b40af21f66c2bec6b6"
                hex"bf71c57236904f35fa68407a46647d6e"
            ); else if (i==6)
            C= bytes(
                hex"f4c70e16eeaac5ec51ac86febf240954"
                hex"399ec6c7e6bf87c9d3473e33197a93c9"
                hex"0992abc52d822c3706476983284a0504"
                hex"3517454ca23c4af38886564d3a14d493"
            ); else if ( i ==7)
            C= bytes(
                hex"9b1f5b424d93c9a703e7aa020c6e4141"
                hex"4eb7f8719c36de1e89b4443b4ddbc49a"
                hex"f4892bcb929b069069d18d2bd1a5c42f"
                hex"36acc2355951a8d9a47f0dd4bf02e71e"
            ); else if (i == 8)
            C= bytes(
                hex"378f5a541631229b944c9ad8ec165fde"
                hex"3a7d3a1b258942243cd955b7e00d0984"
                hex"800a440bdbb2ceb17b2b8a9aa6079c54"
                hex"0e38dc92cb1f2a607261445183235adb"
            ); else if (i==9)
            C= bytes(
                hex"abbedea680056f52382ae548b2e4f3f3"
                hex"8941e71cff8a78db1fffe18a1b336103"
                hex"9fe76702af69334b7a1e6c303b7652f4"
                hex"3698fad1153bb6c374b4c7fb98459ced"
            ); else if (i==10)
            C=  bytes(
                hex"7bcd9ed0efc889fb3002c6cd635afe94"
                hex"d8fa6bbbebab07612001802114846679"
                hex"8a1d71efea48b9caefbacd1d7d476e98"
                hex"dea2594ac06fd85d6bcaa4cd81f32d1b"
            ); else if (i==11)
            C= bytes(
                hex"378ee767f11631bad21380b00449b17a"
                hex"cda43c32bcdf1d77f82012d430219f9b"
                hex"5d80ef9d1891cc86e71da4aa88e12852"
                hex"faf417d5d9b21b9948bc924af11bd720"
            );

        return C;
    }
}
