`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.03.2025 11:59:43
// Design Name: 
// Module Name: tb_mlkem
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_mlkem_v2();

    parameter PERIOD = 10;
    parameter CYCLES = 10;
    parameter VERBOSE = 2;
    parameter N_TEST = 1;
    parameter RANDOM = 0;
    parameter VERBOSE_RANDOM = 0;
    
    parameter MASKED = 0;
    parameter N_BU = 1;
    parameter SHUFF = 1;
    parameter SHUFF_DELAY = 540;
    parameter KECCAK_PROT = 0;
    
    parameter RESET         = 4'h0;
    parameter LOAD_R0       = 4'h1;
    parameter READ_R0       = 4'h2;
    parameter LOAD_R1       = 4'h3;
    parameter READ_R1       = 4'h4;
    parameter LOAD_HEK      = 4'h5;
    parameter READ_HEK      = 4'h6;
    parameter LOAD_SS       = 4'h7;
    parameter READ_SS       = 4'h8;
    parameter LOAD_DK       = 4'h9;
    parameter READ_DK       = 4'hA;
    parameter LOAD_EK       = 4'hB;
    parameter READ_EK       = 4'hC;
    parameter LOAD_CT       = 4'hD;
    parameter READ_CT       = 4'hE; 
    parameter START         = 4'hF;
    
    parameter GEN_KEYS_512  = 4'b0101;
    parameter GEN_KEYS_768  = 4'b0110;
    parameter GEN_KEYS_1024 = 4'b0111;
    parameter ENCAP_512     = 4'b1001;
    parameter ENCAP_768     = 4'b1010;
    parameter ENCAP_1024    = 4'b1011;
    parameter DECAP_512     = 4'b1101;
    parameter DECAP_768     = 4'b1110;
    parameter DECAP_1024    = 4'b1111;
    
    reg             clk;
    reg             rst;
    wire    [7:0]   control;
    reg     [3:0]   oper;
    reg     [3:0]   mode;
    assign          control = {mode, oper};
    
    reg     [63:0]  r_in;
    reg     [15:0]  add;
    
    wire    [63:0]  r_out;
    wire    [1:0]   end_op;
    
    reg     [7:0]  ek_array         [0:1568-1];
    reg     [7:0]  dk_array         [0:3168-1];
    reg     [63:0]  d_array         [0:3];
    reg     [63:0]  z_array         [0:3];
    reg     [63:0]  m_array         [0:3];
    reg     [7:0]   ct_array        [0:2047];
    reg     [7:0]  ss_array          [0:31];
    reg     [7:0]  ss2_array         [0:31];
    
    integer i;
    integer j;
    integer comp;
    integer test;
    integer K;
    integer i_end;
    integer add_2;
    integer off;
    
    integer LEN_EK;
    integer LEN_DK;
    integer LEN_CT;
    integer LEN_PKE;
    
    integer counter_cycles;
    wire flag_op;
    
    AXI_IO_MLKEM #(
    .MASKED(MASKED),
    .N_BU(N_BU),
    .SHUFF(SHUFF),
    .SHUFF_DELAY(SHUFF_DELAY),
    .KECCAK_PROT(KECCAK_PROT)
    )
    AXI_IO_MLKEM
    (   .clk(clk), .rst(rst), 
        .control(control), .end_op(end_op),
        .add(add), .data_in(r_in), .data_out(r_out),
        .flag_op(flag_op));
        
    initial begin
    K = 3;
    add = 0;
    r_in = 0;
    mode = 0;
    counter_cycles = 0;
    
    
    rst = 1; oper = RESET; #(CYCLES * 10 * PERIOD); // INIT MODULE
    rst = 0; oper = RESET; #(CYCLES * 11 * PERIOD); // RESET MODULE
    rst = 1; oper = RESET; #(CYCLES * 10 * PERIOD); // INIT MO
    
    K = 3; GEN_COINS(); TEST();
    
    /*
    for (test = 0; test < N_TEST; test = test + 1) begin
        K = 2; GEN_COINS(); TEST();
    end
    */
    /*
    for (test = 0; test < N_TEST; test = test + 1) begin
        K = 3; GEN_COINS(); TEST();
    end
    
    for (test = 0; test < N_TEST; test = test + 1) begin
        K = 4; GEN_COINS(); TEST();
    end
    */
    
    /*
    for (test = 0; test < N_TEST; test = test + 1) begin
        K = 2;  TEST();
    end
    for (test = 0; test < N_TEST; test = test + 1) begin
        K = 3;  TEST();
    end
    for (test = 0; test < N_TEST; test = test + 1) begin
        K = 4;  TEST();
    end
    */
    
    
end

// generate clock
    always     
        begin 
            clk=0; #(PERIOD/2); clk=1; #(PERIOD/2); 
		end
		
task GEN_COINS();
        begin
            
            if(RANDOM == 0) begin
                
                d_array[0]      = 64'h51_9d_62_01_0a_40_b4_1e;
                d_array[1]      = 64'hf5_de_b9_85_cd_e2_74_79;
                d_array[2]      = 64'h2b_9c_6f_8e_50_de_82_90;
                d_array[3]      = 64'hca_55_59_96_12_1e_34_0e;

                z_array[0]      = 64'hfe_03_38_16_11_41_39_1a;
                z_array[1]      = 64'h75_86_a6_35_c3_19_85_2e;
                z_array[2]      = 64'h5f_2b_a2_af_ad_8e_33_56;
                z_array[3]      = 64'h93_d6_cc_60_05_43_57_c5;
                
                m_array[0]      = 64'h72_40_7c_18_ae_6c_9b_af;
                m_array[1]      = 64'h10_70_e3_3b_3f_9d_fc_56;
                m_array[2]      = 64'h28_a1_87_e6_d0_55_af_ff;
                m_array[3]      = 64'hd3_84_68_eb_62_7f_7c_f1;
                

            end
            else begin
                for (i = 0; i < 4; i = i + 1) begin
                    // d_array[i] = {$urandom%65536,$urandom%65536,$urandom%65536,$urandom%65536};
                    // z_array[i] = {$urandom%65536,$urandom%65536,$urandom%65536,$urandom%65536};
                    // m_array[i] = {$urandom%65536,$urandom%65536,$urandom%65536,$urandom%65536}; 
                    d_array[i] = {$urandom,$urandom,$urandom,$urandom};
                    z_array[i] = {$urandom,$urandom,$urandom,$urandom};
                    m_array[i] = {$urandom,$urandom,$urandom,$urandom}; 
                end
                if (VERBOSE_RANDOM) begin
                // ---- PRINT d ---- //
                $write("\n");
                for (i = 0; i < 4; i = i + 1) begin
                    $write("0x%016x\n",d_array[i]);
                end
                // ---- PRINT m ---- //
                $write("\n");
                for (i = 0; i < 4; i = i + 1) begin
                    $write("0x%016x\n",m_array[i]);
                end
                // ---- PRINT z ---- //
                $write("\n");
                for (i = 0; i < 4; i = i + 1) begin
                    $write("0x%016x\n",z_array[i]);
                end
            end
            end
        end
    endtask
    
    task TEST();
        begin
            // ----------------------------- //
            // ---------- KEY GEN ---------  //
            // ----------------------------- //
            if(K == 2) mode = GEN_KEYS_512;
            if(K == 3) mode = GEN_KEYS_768;
            if(K == 4) mode = GEN_KEYS_1024;
            
            if(K == 2) LEN_EK = 800 - 32;
            if(K == 3) LEN_EK = 1184 - 32;
            if(K == 4) LEN_EK = 1568 - 32;
            
            if(K == 2) LEN_DK = 1632 - LEN_EK - 32 - 32 - 32; // rho, H(ek), z
            if(K == 3) LEN_DK = 2400 - LEN_EK - 32 - 32 - 32;
            if(K == 4) LEN_DK = 3168 - LEN_EK - 32 - 32 - 32;
        
            // ------ RESET ------ //
            rst = 1; oper = RESET;  #(CYCLES * 10 * PERIOD); // INIT MO
            
            if(MASKED)
                rst = 1; oper = LOAD_R0;  #(1000 * CYCLES * PERIOD); // CYCLES TO SETUP SHARES
            
            // ---- LOAD_COINS ---- //
            rst = 1; oper = LOAD_R0;  #(CYCLES * PERIOD); // LOAD_COINS
            for (i = 0; i < 4; i = i + 1) begin
                add     = i;                #(CYCLES * PERIOD);
                r_in    = d_array[i];   #(CYCLES * PERIOD);
            end
            
            /* No needed for this version of MLKEM -> It has to be stored in an upper layer
            // ---- LOAD_Z ---- //
            rst = 1; oper = LOAD_R1;  #(CYCLES * PERIOD); // LOAD_Z
            for (i = 0; i < 4; i = i + 1) begin
                add     = i;                #(CYCLES * PERIOD);
                r_in    = z_array[i];       #(CYCLES * PERIOD);
            end
            */
            
            // ------ START ------ //
            rst = 1; oper = START;  // START // #(CYCLES * PERIOD); 
            
            counter_cycles = 0;
            while(!end_op[0]) begin 
                #(PERIOD);
                if(flag_op) counter_cycles = counter_cycles + 1;
            end
        
            #(CYCLES * 10 * PERIOD);
            
            // ---- READ EK ---- //
            rst = 1; oper = READ_EK;  #(CYCLES * PERIOD); // READ_EK (EK_PKE)
            for (i = 0; i < LEN_EK / 8; i = i + 1) begin
                add                 = i;                #(CYCLES * PERIOD);                                                                  
                ek_array[8*i + 0] = r_out[07:00];     
                ek_array[8*i + 1] = r_out[15:08]; 
                ek_array[8*i + 2] = r_out[23:16];     
                ek_array[8*i + 3] = r_out[31:24];        
                ek_array[8*i + 4] = r_out[39:32];     
                ek_array[8*i + 5] = r_out[47:40]; 
                ek_array[8*i + 6] = r_out[55:48];     
                ek_array[8*i + 7] = r_out[63:56]; 
                
                off = LEN_DK / 8;
                dk_array[8*(off+i) + 0] = r_out[07:00];     
                dk_array[8*(off+i) + 1] = r_out[15:08]; 
                dk_array[8*(off+i) + 2] = r_out[23:16];     
                dk_array[8*(off+i) + 3] = r_out[31:24];        
                dk_array[8*(off+i) + 4] = r_out[39:32];     
                dk_array[8*(off+i) + 5] = r_out[47:40]; 
                dk_array[8*(off+i) + 6] = r_out[55:48];     
                dk_array[8*(off+i) + 7] = r_out[63:56]; 
                
                #(CYCLES * PERIOD);
            end
            rst = 1; oper = READ_R0;  #(CYCLES * PERIOD); // READ_EK (RHO)
            for (i = 0; i < 4; i = i + 1) begin
                add                 = i;                #(CYCLES * PERIOD);                                                                  
                ek_array[8*(LEN_EK/8 + i) + 0] = r_out[07:00];     
                ek_array[8*(LEN_EK/8 + i) + 1] = r_out[15:08]; 
                ek_array[8*(LEN_EK/8 + i) + 2] = r_out[23:16];     
                ek_array[8*(LEN_EK/8 + i) + 3] = r_out[31:24];        
                ek_array[8*(LEN_EK/8 + i) + 4] = r_out[39:32];     
                ek_array[8*(LEN_EK/8 + i) + 5] = r_out[47:40]; 
                ek_array[8*(LEN_EK/8 + i) + 6] = r_out[55:48];     
                ek_array[8*(LEN_EK/8 + i) + 7] = r_out[63:56]; 
                
                off = (LEN_DK + LEN_EK) / 8;
                dk_array[8*(off + i) + 0] = r_out[07:00];     
                dk_array[8*(off + i) + 1] = r_out[15:08]; 
                dk_array[8*(off + i) + 2] = r_out[23:16];     
                dk_array[8*(off + i) + 3] = r_out[31:24];        
                dk_array[8*(off + i) + 4] = r_out[39:32];     
                dk_array[8*(off + i) + 5] = r_out[47:40]; 
                dk_array[8*(off + i) + 6] = r_out[55:48];     
                dk_array[8*(off + i) + 7] = r_out[63:56]; 
                
                #(CYCLES * PERIOD);
            end
            
            
            // ---- READ DK ---- //
            rst = 1; oper = READ_DK;  #(CYCLES * PERIOD); // READ_DK (DK_PKE)
            for (i = 0; i < (LEN_DK / 8); i = i + 1) begin
                add                 = i;                #(CYCLES * PERIOD);                                                                  
                dk_array[8*i + 0] = r_out[07:00];     
                dk_array[8*i + 1] = r_out[15:08]; 
                dk_array[8*i + 2] = r_out[23:16];     
                dk_array[8*i + 3] = r_out[31:24];        
                dk_array[8*i + 4] = r_out[39:32];     
                dk_array[8*i + 5] = r_out[47:40]; 
                dk_array[8*i + 6] = r_out[55:48];     
                dk_array[8*i + 7] = r_out[63:56]; 
                #(CYCLES * PERIOD);
            end
            
            rst = 1; oper = READ_HEK;  #(CYCLES * PERIOD); // READ_DK (HEK)
            for (i = 0; i < 4; i = i + 1) begin
                add                 = i;                #(CYCLES * PERIOD);   
                off = (LEN_DK + LEN_EK + 32) / 8;                                                               
                dk_array[8*(off + i) + 0] = r_out[07:00];     
                dk_array[8*(off + i) + 1] = r_out[15:08]; 
                dk_array[8*(off + i) + 2] = r_out[23:16];     
                dk_array[8*(off + i) + 3] = r_out[31:24];        
                dk_array[8*(off + i) + 4] = r_out[39:32];     
                dk_array[8*(off + i) + 5] = r_out[47:40]; 
                dk_array[8*(off + i) + 6] = r_out[55:48];     
                dk_array[8*(off + i) + 7] = r_out[63:56]; 
                #(CYCLES * PERIOD);
            end
            
            // rst = 1; oper = READ_HEK;  #(CYCLES * PERIOD); // READ_DK (HEK)
            // READ Z ... Already in the system
            for (i = 0; i < 4; i = i + 1) begin
                add                 = i;                #(CYCLES * PERIOD); 
                off = (LEN_DK + LEN_EK + 32 + 32) / 8;                                                                 
                dk_array[8*(off + i) + 0] = z_array[add][07:00];     
                dk_array[8*(off + i) + 1] = z_array[add][15:08]; 
                dk_array[8*(off + i) + 2] = z_array[add][23:16];     
                dk_array[8*(off + i) + 3] = z_array[add][31:24];        
                dk_array[8*(off + i) + 4] = z_array[add][39:32];     
                dk_array[8*(off + i) + 5] = z_array[add][47:40]; 
                dk_array[8*(off + i) + 6] = z_array[add][55:48];     
                dk_array[8*(off + i) + 7] = z_array[add][63:56]; 
                #(CYCLES * PERIOD);
            end

        
            if (VERBOSE >= 2) begin
                // ---- PRINT ek ---- //
                $write("\n");
                for (i = 0; i < (LEN_EK+32); i = i + 1) begin
                    if(i % 32 == 0) $write("\n");
                    $write("%02x",ek_array[i]);
                end
                // ---- PRINT dk ---- //
                $write("\n");
                for (i = 0; i < (LEN_DK+LEN_EK+32+32+32); i = i + 1) begin
                    if(i % 32 == 0) $write("\n");
                    $write("%02x",dk_array[i]);
                end
            end
            
        
        // -------------------------------- //
        // -------- ENCAPSULATION --------  //
        // ------------------------------- //
        if(K == 2) mode = ENCAP_512;
        if(K == 3) mode = ENCAP_768;
        if(K == 4) mode = ENCAP_1024;
        
        if(K == 2) LEN_CT = 768;
        if(K == 3) LEN_CT = 1088;
        if(K == 4) LEN_CT = 1568;
        
        counter_cycles = 0;
         
        // ------ LOAD_EK ------ //
        rst = 1; oper = RESET; #(CYCLES * 10 * PERIOD); // INIT MO
        
        if(MASKED)
                rst = 1; oper = LOAD_EK;  #(1000 * CYCLES * PERIOD); // CYCLES TO SETUP SHARES
        
        rst = 1; oper = LOAD_EK;  #(CYCLES * PERIOD); // LOAD PK
        for (i = 0; i < ((LEN_EK - 32) / 8); i = i + 1) begin
            add     = i;            #(CYCLES * PERIOD);
            r_in    = { ek_array[8*i+7], ek_array[8*i+6],
                        ek_array[8*i+5], ek_array[8*i+4],
                        ek_array[8*i+3], ek_array[8*i+2], 
                        ek_array[8*i+1], ek_array[8*i+0]};  #(CYCLES * PERIOD);
        end
        #(CYCLES * PERIOD);
        
        // ------ LOAD_SEED ------ //
        add_2   = (LEN_EK-32);
        rst = 1; oper = LOAD_R0;  #(CYCLES*PERIOD); // LOAD SEED
        for (i = 0; i < 4; i = i + 1) begin
            add     = i;                                #(CYCLES*PERIOD);
            add_2   = 8*i + (LEN_EK);
            r_in    = { ek_array[add_2+7], ek_array[add_2+6],
                        ek_array[add_2+5], ek_array[add_2+4],
                        ek_array[add_2+3], ek_array[add_2+2], 
                        ek_array[add_2+1], ek_array[add_2+0]};
            #(CYCLES*PERIOD);
        end
        #(CYCLES*PERIOD);
        
        // ------ LOAD_M ------ //
        rst = 1; oper = LOAD_SS;  #(CYCLES * PERIOD); // LOAD SS
        for (i = 0; i < 4; i = i + 1) begin
            add     = i;             #(CYCLES*PERIOD);
            r_in    = m_array[i];    #(CYCLES*PERIOD);
        end
        #(CYCLES * PERIOD);
        
        // ------ START ------ //
        rst = 1; oper = START;  // START // #(CYCLES * PERIOD); 
        
        counter_cycles = 0;
        while(!end_op[0]) begin 
            #(PERIOD);
            if(flag_op) counter_cycles = counter_cycles + 1;
        end
        
        #(CYCLES*PERIOD);
        
        // ---- READ CIPHERTEXT ---- //
        rst = 1; oper = READ_CT;  #(CYCLES * PERIOD); // READ_CT
        for (i = 0; i < (LEN_CT / 8); i = i + 1) begin
            add                 = i;                #(CYCLES * PERIOD);                                                                  
            ct_array[8*i + 0] = r_out[07:00];     
            ct_array[8*i + 1] = r_out[15:08]; 
            ct_array[8*i + 2] = r_out[23:16];     
            ct_array[8*i + 3] = r_out[31:24];        
            ct_array[8*i + 4] = r_out[39:32];     
            ct_array[8*i + 5] = r_out[47:40]; 
            ct_array[8*i + 6] = r_out[55:48];     
            ct_array[8*i + 7] = r_out[63:56]; 
            #(CYCLES * PERIOD);
        end
        
        // ------ READ_SS ------ //
        rst = 1; oper = READ_SS;  #(CYCLES * PERIOD); // READ_SK
        for (i = 0; i < 4; i = i + 1) begin
            add                 = i + (LEN_CT / 8);                #(CYCLES * PERIOD);                                                                  
            ss_array[8*i + 0] = r_out[07:00];     
            ss_array[8*i + 1] = r_out[15:08]; 
            ss_array[8*i + 2] = r_out[23:16];     
            ss_array[8*i + 3] = r_out[31:24];        
            ss_array[8*i + 4] = r_out[39:32];     
            ss_array[8*i + 5] = r_out[47:40]; 
            ss_array[8*i + 6] = r_out[55:48];     
            ss_array[8*i + 7] = r_out[63:56]; 
            #(CYCLES * PERIOD);
        end
        
        // ---- PRINT CIPHERTEXT ---- //
        if(VERBOSE >= 2) begin
            $write("\n");
            for (i = 0; i < LEN_CT; i = i + 1) begin
                if(i % 32 == 0) $write("\n");
                $write("%02x",ct_array[i]);
            end
        end
        
        // ---- PRINT SS ---- //
        if(VERBOSE >= 1) begin
            $write("\n"); $write("\t K: %d \t TEST: %d", K, test);
            for (i = 0; i < 32; i = i + 1) begin
                if(i % 32 == 0) $write("\n");
                $write("%02x",ss_array[i]);
            end
        end
        
        // -------------------------------- //
        // -------- DECAPSULATION --------  //
        // -------------------------------- //
        
        if(K == 2) mode = DECAP_512;
        if(K == 3) mode = DECAP_768;
        if(K == 4) mode = DECAP_1024;
        
        counter_cycles = 0;
        
        // ------ LOAD_DK ------ //
        rst = 1; oper = RESET; #(CYCLES * PERIOD); // INIT MO
        
        // ---- DK  (LOAD DK_PKE) ----  //
        rst = 1; oper = LOAD_DK;  #(CYCLES * PERIOD);    // LOAD DK (DK_PKE)
        for (i = 0; i < LEN_DK / 8; i = i + 1) begin
            add                 = i;                #(CYCLES * PERIOD);                                                                  
            r_in    = { dk_array[8*i+7], dk_array[8*i+6],
                        dk_array[8*i+5], dk_array[8*i+4],
                        dk_array[8*i+3], dk_array[8*i+2], 
                        dk_array[8*i+1], dk_array[8*i+0]};
            
            #(CYCLES * PERIOD);
        end
        
        // ---- DK  (LOAD EK_PKE) ----  //
        rst = 1; oper = LOAD_EK;  #(CYCLES * PERIOD);   // LOAD_EK (EK_PKE)
        for (i = 0; i < LEN_EK / 8; i = i + 1) begin
            add                 = i;                #(CYCLES * PERIOD);                                                                  
            off = LEN_DK / 8;
            
            r_in    = { dk_array[8*(off+i)+7], dk_array[8*(off+i)+6],
                        dk_array[8*(off+i)+5], dk_array[8*(off+i)+4],
                        dk_array[8*(off+i)+3], dk_array[8*(off+i)+2], 
                        dk_array[8*(off+i)+1], dk_array[8*(off+i)+0]};
            
            #(CYCLES * PERIOD);
        end
        
        
        // ---- LOAD CIPHERTEXT ---- //
        rst = 1; oper = LOAD_CT;  #(CYCLES * PERIOD); // LOAD CT
        for (i = 0; i < (LEN_CT / 8); i = i + 1) begin
            add     = i;                                    #(CYCLES * PERIOD);
            r_in    = { ct_array[8*i+7], ct_array[8*i+6],
                        ct_array[8*i+5], ct_array[8*i+4],
                        ct_array[8*i+3], ct_array[8*i+2], 
                        ct_array[8*i+1], ct_array[8*i+0]};  #(CYCLES * PERIOD);
        end
        #(CYCLES * PERIOD);
        
        // ------ LOAD_SEED ------ //
        add_2   = (LEN_EK-32);
        rst = 1; oper = LOAD_R0;  #(CYCLES*PERIOD); // LOAD RHO
        for (i = 0; i < 4; i = i + 1) begin
            add     = i;                                #(CYCLES*PERIOD);
            off = (LEN_DK + LEN_EK) / 8;
            add_2   = 8*(off + i);
            r_in    = { dk_array[add_2+7], dk_array[add_2+6],
                        dk_array[add_2+5], dk_array[add_2+4],
                        dk_array[add_2+3], dk_array[add_2+2], 
                        dk_array[add_2+1], dk_array[add_2+0]};
            #(CYCLES*PERIOD);
        end
        #(CYCLES*PERIOD);
        
        // ------ LOAD_HEK ------ //
        rst = 1; oper = LOAD_HEK;  #(CYCLES * PERIOD);    // LOAD HK
        for (i = 0; i < 4; i = i + 1) begin
            add     = i;            #(CYCLES * PERIOD);
            off = (LEN_DK + LEN_EK + 32) / 8;
            add_2   = 8*(off + i);
            r_in    = { dk_array[add_2+7], dk_array[add_2+6],
                        dk_array[add_2+5], dk_array[add_2+4],
                        dk_array[add_2+3], dk_array[add_2+2], 
                        dk_array[add_2+1], dk_array[add_2+0]};  #(CYCLES * PERIOD);
        end
       
        #(CYCLES * PERIOD);
        
        // ------ LOAD_Z ------ //
        rst = 1; oper = LOAD_R1;  #(CYCLES * PERIOD);    // LOAD Z
        for (i = 0; i < 4; i = i + 1) begin
            add     = i;            #(CYCLES * PERIOD);
            off = (LEN_DK + LEN_EK + 32 + 32) / 8;
            add_2   = 8*(off + i);
            r_in    = { dk_array[add_2+7], dk_array[add_2+6],
                        dk_array[add_2+5], dk_array[add_2+4],
                        dk_array[add_2+3], dk_array[add_2+2], 
                        dk_array[add_2+1], dk_array[add_2+0]};  #(CYCLES * PERIOD);
        end
        #(CYCLES * PERIOD);
        
        // ------ START ------ //
        rst = 1; oper = START;  // START // #(CYCLES * PERIOD); 
        
        counter_cycles = 0;
        while(!end_op[0]) begin 
            #(PERIOD);
            if(flag_op) counter_cycles = counter_cycles + 1;
        end
        
        #(CYCLES * 10 * PERIOD);
        
        // ---- READ SS ---- //
        rst = 1; oper = READ_SS;  #(CYCLES * PERIOD); // READ SS
        for (i = 0; i < 4; i = i + 1) begin
            add                 = i;                #(CYCLES * PERIOD);                                                                  
            ss2_array[8*i + 0] = r_out[07:00];     
            ss2_array[8*i + 1] = r_out[15:08]; 
            ss2_array[8*i + 2] = r_out[23:16];     
            ss2_array[8*i + 3] = r_out[31:24];        
            ss2_array[8*i + 4] = r_out[39:32];     
            ss2_array[8*i + 5] = r_out[47:40]; 
            ss2_array[8*i + 6] = r_out[55:48];     
            ss2_array[8*i + 7] = r_out[63:56]; 
            #(CYCLES * PERIOD);
        end
        
        // ---- PRINT SS ---- //
        comp = 0; 
        if(VERBOSE >= 1) begin
            for (i = 0; i < 32; i = i + 1) begin
                if(ss_array[i] != ss2_array[i]) comp = 1; 
                
                if(i % 32 == 0) $write("\n");
                $write("%02x",ss2_array[i]);
            end
            
            if(comp) $write("\t COMP: FAIL");
            else     $write("\t COMP: OK");
            
            if(end_op == 2'b01) $write("\t RESULT: FAIL");
            else $write("\t RESULT: OK");
        end
        end

    endtask
  
endmodule
