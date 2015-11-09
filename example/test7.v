
module  test7 (

//Local Bus
    input                       mpif_clk ,   // Local bus clock
    input        [9:0]          mpif_addr  , // Local bus address
    input       [15:0]          mpif_wdata , // Local bus write data

//Common
    input                       rst_n,
    input                       clk_25m,

    output                      EDFA_MUTE7_MODULE2

);


/*************************** COMMON ******************************/
    parameter   DEVICE_ID               = 16'h0466;
    parameter   REV                     = 16'hF410;

    parameter   DEVICE_ID_ADDR          = 10'h000;
    parameter   REV_ADDR                = 10'h001;
    parameter   SCRATCH_1_ADDR          = 10'h002;
    assign module_type_change = {module2_type_change_flag, module1_type_change_flag, module0_type_change_flag};

/************************* Local Bus *****************************/
    reg     [15:0]      scratch_1, scratch_2;
    reg                 mcs0_spi_data_over, mcs1_spi_data_over, mcs2_spi_data_over;
    always @(posedge mpif_clk or negedge rst_n)
    begin
        if (!rst_n)
            begin
                scratch_1               <=  16'h5555;
                scratch_2               <=  16'haaaa;
                SFP_TX_DISABLE_MODULE0  <=  1'b0;
                SFP_TX_DISABLE_MODULE1  <=  1'b0;
                SFP_TX_DISABLE_MODULE2  <=  1'b0;
                module0_mute            <=  8'hff;
                module1_mute            <=  8'hff;
                module2_mute            <=  8'hff;
                p2040_instruction_reg0  <=  16'h0;
                p2040_instruction_reg1  <=  16'h0;
                p2040_instruction_reg2  <=  16'h0;
                mcs0_spi_data_over      <=  1'b0;
                mcs1_spi_data_over      <=  1'b0;
                mcs2_spi_data_over      <=  1'b0;
            end
        else
            begin
                if (mpif_we && mpif_cs && mpif_addr == SCRATCH_1_ADDR)
                    scratch_1           <= mpif_wdata;
                if (mpif_we && mpif_cs && mpif_addr == SCRATCH_2_ADDR)
                    scratch_2           <= mpif_wdata;
                if (mpif_we && mpif_cs && mpif_addr == CARD_SFP_DIS_ADDR)
                    begin
                        SFP_TX_DISABLE_MODULE2  <= mpif_wdata[2];
                        SFP_TX_DISABLE_MODULE1  <= mpif_wdata[1];
                        SFP_TX_DISABLE_MODULE0  <= mpif_wdata[0];
                    end
                if (mpif_we && mpif_cs && mpif_addr == CARD2_P2040_INS_ADDR)
                    p2040_instruction_reg2   <= mpif_wdata[15:0];
                if ((mpif_we && mpif_cs && mpif_addr == CARD0_SPI_ADDR) ||
                    ((p2040_instruction_reg0 !== 16'hf) && (p2040_instruction_reg0 !== 16'hAA)))
                    mcs0_spi_data_over      <= 1'b0;
                else if((mcs0_spi_addr == 16'h0ffc) && (mcs0_spi_addr_r0 == 16'h0ffe))
                    mcs0_spi_data_over      <= 1'b1;
                if ((mpif_we && mpif_cs && mpif_addr == CARD1_SPI_ADDR) ||
                    ((p2040_instruction_reg1 !== 16'hf) && (p2040_instruction_reg1 !== 16'hAA)))
                    mcs1_spi_data_over      <= 1'b0;
                else if((mcs1_spi_addr == 16'h0ffc) && (mcs1_spi_addr_r0 == 16'h0ffe))
                    mcs1_spi_data_over      <= 1'b1;
                if ((mpif_we && mpif_cs && mpif_addr == CARD2_SPI_ADDR) ||
                    ((p2040_instruction_reg2 !== 16'hf) && (p2040_instruction_reg2 !== 16'hAA)))
                    mcs2_spi_data_over      <= 1'b0;
                else if((mcs2_spi_addr == 16'h0ffc) && (mcs2_spi_addr_r0 == 16'h0ffe))
                    mcs2_spi_data_over      <= 1'b1;
            end
    end

// MPIF read operation
    always @(*)
    begin
        mpif_rdata = 16'h0;
        if ( mpif_cs )
            case(mpif_addr)
                DEVICE_ID_ADDR                  : mpif_rdata = DEVICE_ID;
                REV_ADDR                        : mpif_rdata = REV;
                SCRATCH_1_ADDR                  : mpif_rdata = scratch_1;
                SCRATCH_2_ADDR                  : mpif_rdata = scratch_2;
                CARD0_MUTE_ADDR                 : mpif_rdata = module0_mute;
                CARD1_MUTE_ADDR                 : mpif_rdata = module1_mute;
                CARD2_MUTE_ADDR                 : mpif_rdata = module2_mute;
                CARD0_P2040_INS_ADDR            : mpif_rdata = p2040_instruction_reg0[15:0];
                CARD0_PD1_DATA_ADDR             : mpif_rdata = mcs0_pd1_data[15:0];
                CARD0_PD2_DATA_ADDR             : mpif_rdata = mcs0_pd2_data[15:0];
                CARD0_SPI_ADDR                  : mpif_rdata = mcs0_spi_data_over;
                CARD1_REV_LO_ADDR               : mpif_rdata = mcs1_rev_lo;
                CARD2_REV_HI_ADDR               : mpif_rdata = mcs2_rev_hi;
                CARD2_REV_LO_ADDR               : mpif_rdata = mcs2_rev_lo;
                MODULE_TYPE_CHANGE_ADDR         : mpif_rdata = module_type_change;
                default : mpif_rdata = 16'h0;
            endcase
    end

endmodule
