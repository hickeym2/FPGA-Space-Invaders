module test2 (
	//input
	clk, key, shootButton,
	//output
	VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_R, VGA_G, VGA_B,
	);
	
	input clk;
	input [3:0] key;
	input shootButton;
	///////// VGA /////////
	output VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N;
	output [ 7: 0] VGA_R, VGA_G, VGA_B;

	//	For VGA Controller
	reg	[9:0]	mRed;
	reg	[9:0]	mGreen;
	reg	[9:0]	mBlue;
	wire	[10:0]	VGA_X;
	wire	[10:0]	VGA_Y;
	wire			VGA_Read;	//	VGA data request
	wire			DLY2;

	//wire			m1VGA_Read;	//	Read odd field
	//wire			m2VGA_Read;	//	Read even field

	//	VGA Controller
	wire [9:0] vga_r10;
	wire [9:0] vga_g10;
	wire [9:0] vga_b10;
	assign VGA_R = vga_r10[9:2];
	assign VGA_G = vga_g10[9:2];
	assign VGA_B = vga_b10[9:2];
	
	///Ship Variable Initialization///
	//For convenience//
	//integer xmid;
	//integer ymid;
	//position//
	//integer ship_x;
	//integer ship_y;
	//tanks//
	//integer ship_fin_left;		//rear ship component left
	//integer ship_fin_right;		//rear ship component right
	//Hull//
	integer ship_hull_x1;		//ship main component top left
	integer ship_hull_x2;		//ship main component top right
	integer ship_hull_y1;		//ship main component bottom left
	integer ship_hull_y2;		//ship main component bottom right
	//Cockpit//
	//integer ship_cockpit;		//top component of ship
	//ship_color//
	reg [9:0] ship_red;			//ship red value
	reg [9:0] ship_green;		//ship green value
	reg [9:0] ship_blue;			//ship blue value
	
	///Enemy Variable Initialization///
	//hull//
	integer en_hull_x1;			//enemy top left
	integer en_hull_x2;			//enemy top right
	integer en_hull_y1;			//enemy bottom left
	integer en_hull_y2;			//enemy bottom right
	//Enemy Color//
	reg [9:0] en_red;				//enemy red value
	reg [9:0] en_green;			//enemy green value
	reg [9:0] en_blue;			//enemy blue value
	//enemy movement variables
	integer eox, eoy; //enemy offset x and enemy offset y
	integer xFlag, yFlag;
	integer bt1x, bt2x;// the b in y=mx + b for triangle 1 left triangle 
	integer bt1y, bt2y;
	//====================\\
	
	//=== Shooting ===\\
	integer shootFlag;	initial shootFlag 	= 0;
	//integer shootTimer;	initial shootTimer 	= 0;
	//integer bullety;		initial bullety		= 0;
	//integer bulletExist;	initial bulletExist	= 0;
	//integer snapshotx1;	initial snapshotx1	= 0;
	//integer shapshoty1;	initial shapshoty1	= 0;
	integer Testi;			initial Testi 			= 0;
	integer bulletArray[5:0];	
	initial begin
		for( Testi = 0; Testi < 6; Testi = Testi+1)begin
			bulletArray[Testi] = 0;
		end
	end
	integer bulletIter;	initial bulletIter = 0;
	integer bulletSnapx[5:0];
	integer bulletSnapy[5:0];
	integer bulletDistance[5:0];//The distance that the bullet has traveled
	integer timerIter; initial timerIter = 0;//iterate through all the timers
	integer indBullTimer[5:0];//the individual timer that counts for that bullet.
	//================\\
	
	//used for the movement
	//reg [31:0] quarter, offset, moveCounter;//used for movement
	//reg direction;//either forwards or backwards 1 / 0
	 
	initial begin
		//dir = 1;
		//increment = 1;
		bt1x = 526;
		bt2x = 390;
	end
	
	//integer y1, y2, timer, count, dir, arr_r, arr_l, i, arr_b1, arr_x;
	reg clk25;
	integer timer; //used for button presses
	
	always @( posedge clk ) begin

		clk25 = !clk25;
		
		
		///Background///
		mRed = 10'b0000000000;
		mGreen = 10'b0000000000;
		mBlue = 10'b0000000000;
		//Figure out a way to add stars
		
		
		///Ship Vars///
		//xmid = (ship_hull_x2- ship_hull_x1) - ((ship_hull_x2-ship_hull_x1)/2);
		//ymid = (ship_hull_y2 -ship_hull_y1) - ((ship_hull_y2-ship_hull_y1)/2);
		//Ship Position//
		//ship_x = 0;
		//ship_y = 0;
		//Hull//
		ship_hull_x1 = 62+eox;	//100
		ship_hull_x2 = 74+eox;	//150
		ship_hull_y1 = 452+eoy;	//100
		ship_hull_y2 = 476+eoy;	//200
		//Cockpit//
		//ship_cockpit = (ship_cockpit <= ((ship_hull_x2/4-ship_hull_x1/4)/2)**2);		//TODO: check if this works
		//ship_color//
		ship_red = 10'hFFF;		//Should Truncate
		ship_green = 10'h000;	//Should TRuncate
		ship_blue = 10'hFFF;		//Should truncate
		
		
		///Enemy///
		//hull//
		en_hull_x1 = 75;	//prev: 75
		en_hull_x2 = 100;	//prev: 100
		en_hull_y1 = 75;	//prev: 75
		en_hull_y2 = 100;	//prev: 100
		//Enemy Color//
		en_red = 10'hFFF;
		en_green = 10'hFFF;
		en_blue = 10'hFFF;
		
		timer = timer + 1;
		if ( timer == 1250000) begin
			timer = 0;
			
			//=== Ship Movement ===\\
			// "eox" means= enemy offset in the x direction
			//	"eoy" means enemy offset in the y direction
			if(!key[0])begin
				//right
				//xFlag = 1;
				eox = eox + 1;
				bt1x = bt1x + 1;
				bt2x = bt2x - 1;
			end
			if(!key[1])begin
				//left
				eox = eox - 1;
				bt1x = bt1x - 1;
				bt2x = bt2x + 1;
			end
			if(!key[2])begin
				//down
				eoy = eoy + 1;
				bt1y = bt1y + 1;
				bt2y = bt1y - 1;
				//shootFlag = 1;
			end
			if(!key[3])begin
				//up
				eoy = eoy - 1;
				bt1y = bt1y - 1;
				bt2y = bt2y + 1;
			end
		end


		
		
		///Draw Ship///
		//hull//
		if ( (VGA_X >= ship_hull_x1) && (VGA_X <= ship_hull_x2) && (VGA_Y >= ship_hull_y1) && (VGA_Y <= ship_hull_y2) ) begin
			mRed = ship_red;
			mGreen = ship_green;
			mBlue = ship_blue;
		end
		
		///MIKES TRIANGLE LEFT///
		if ( (VGA_X >= ship_hull_x1 - 12) && (VGA_X <= ship_hull_x1) && (VGA_Y >= -VGA_X + bt1x + bt1y) && (VGA_Y <= ship_hull_y2) ) begin
			mRed = 10'hFFF;
			mGreen = 10'h000;
			mBlue = 10'h000;
		end
		
		//MIKES TRIANGLE RIGHT//
		if ( (VGA_X >= ship_hull_x2) && (VGA_X <= ship_hull_x2 + 12) && (VGA_Y >=  VGA_X + bt2x + bt2y) && (VGA_Y <= ship_hull_y2) )begin
			mRed = 10'h0000;
			mGreen = 10'hFFFF;
			mBlue = 10'h000;
		end
		
		//MIKES SIR-CLE//
		if ( (VGA_X - (ship_hull_x1+12/2))**2 + (VGA_Y - ship_hull_y1)**2 <= (12/2)**2 ) begin
			mRed = ship_red;
			mGreen = ship_green;
			mBlue = ship_blue;
		end

		
		//=== Array Shooting ===\\
		if(shootButton)begin//if you pressed the shoot button
			bulletArray[bulletIter] = 1;//set a bullet at an index to be alive.
			shootFlag = 1;
		end
		
		//if you release the shoot button
		if(shootFlag && !shootButton)begin
			shootFlag = 0;
			//the bullet will exist, and take a snapshot of the ships x position.
			if(bulletIter == 6) begin
				bulletIter = 0;//if you have shot 31 bullets set the bullet iteration back to 0.
			end
			
			bulletSnapx[bulletIter] = ship_hull_x1;//take a snapshot of the current ships locaton for that bullet.
			bulletSnapy[bulletIter] = ship_hull_y1;
			bulletIter = bulletIter + 1;//increment to the next bullet

		end
		
		//Iterate through all the timers
		for(timerIter = 0; timerIter < 6; timerIter = timerIter + 1)begin//timerIter will iterate through all the individual timers for the individual bullets
			if(bulletArray[timerIter])begin//if that bullet is alive proceed to increment its timer.
				indBullTimer[timerIter] = indBullTimer[timerIter] + 1;//increment the individual bullet timer
				if(indBullTimer[timerIter] == 781250/4)begin//every 781250/4 clock cycles you can move the bullet once.
					indBullTimer[timerIter] = 0;//reset the bullet timer
					bulletDistance[timerIter] = bulletDistance[timerIter] + 1;//increment the distance the bullet has traveled by 1.
					if(bulletDistance[timerIter] == 430)begin//if the bullet has traveled 430 pixels
						bulletArray[timerIter] = 0;//also the bullet will not be alive after 430 pixels
						bulletDistance[timerIter] = 0;//reset the distance back to 0.
					end
				end
			end
		end

		//Drawing all the bullets if they exist.
		for(Testi = 0; Testi < 6; Testi = Testi + 1)begin//checking to see if every bullet is alive or not.
			if( (bulletArray[Testi]) && (VGA_X >= bulletSnapx[Testi] + 5) && (VGA_X <= bulletSnapx[Testi] + 7) && (VGA_Y >= bulletSnapy[Testi] - bulletDistance[Testi] -12) && (VGA_Y <= bulletSnapy[Testi] - bulletDistance[Testi] -6) )begin
				mRed 		= 10'h000;
				mGreen 	= 10'h000;
				mBlue 	= 10'h3FF;
			end
		end
		//================\\
		
		
		///Draw Enemy///
		if ( (VGA_X <= en_hull_x2 + eox) && (VGA_X >= en_hull_x1 + eox) && (VGA_Y <= en_hull_y2 + eoy) && (VGA_Y >= en_hull_y1 + eoy) ) begin
			mRed = en_red;
			mGreen = en_green;
			mBlue = en_blue;
		end
		
	end//end of always @(clk)
	
	
	
	VGA_Ctrl			u9	(	//	Host Side
							.iRed(mRed),
							.iGreen(mGreen),
							.iBlue(mBlue),
							.oCurrent_X(VGA_X),
							.oCurrent_Y(VGA_Y),
							.oRequest(VGA_Read),
							//	VGA Side
							.oVGA_R(vga_r10 ),
							.oVGA_G(vga_g10 ),
							.oVGA_B(vga_b10 ),
							.oVGA_HS(VGA_HS),
							.oVGA_VS(VGA_VS),
							.oVGA_SYNC(VGA_SYNC_N),
							.oVGA_BLANK(VGA_BLANK_N),
							.oVGA_CLOCK(VGA_CLK),
							//	Control Signal
							.iCLK(clk25),
							.iRST_N(1)	);
endmodule

module	VGA_Ctrl	(	//	Host Side
						iRed,
						iGreen,
						iBlue,
						oCurrent_X,
						oCurrent_Y,
						oAddress,
						oRequest,
						//	VGA Side
						oVGA_R,
						oVGA_G,
						oVGA_B,
						oVGA_HS,
						oVGA_VS,
						oVGA_SYNC,
						oVGA_BLANK,
						oVGA_CLOCK,
						//	Control Signal
						iCLK,
						iRST_N	);
	//	Host Side
	input		[9:0]	iRed;
	input		[9:0]	iGreen;
	input		[9:0]	iBlue;
	output		[21:0]	oAddress;
	output		[10:0]	oCurrent_X;
	output		[10:0]	oCurrent_Y;
	output				oRequest;
	//	VGA Side
	output		[9:0]	oVGA_R;
	output		[9:0]	oVGA_G;
	output		[9:0]	oVGA_B;
	output	reg			oVGA_HS;
	output	reg			oVGA_VS;
	output				oVGA_SYNC;
	output				oVGA_BLANK;
	output				oVGA_CLOCK;
	//	Control Signal
	input				iCLK;
	input				iRST_N;	
	//	Internal Registers
	reg			[10:0]	H_Cont;
	reg			[10:0]	V_Cont;
	////////////////////////////////////////////////////////////
	//	Horizontal	Parameter
	parameter	H_FRONT	=	16;
	parameter	H_SYNC	=	96;
	parameter	H_BACK	=	48;
	parameter	H_ACT	=	640;
	parameter	H_BLANK	=	H_FRONT+H_SYNC+H_BACK;
	parameter	H_TOTAL	=	H_FRONT+H_SYNC+H_BACK+H_ACT;
	////////////////////////////////////////////////////////////
	//	Vertical Parameter
	parameter	V_FRONT	=	11;
	parameter	V_SYNC	=	2;
	parameter	V_BACK	=	31;
	parameter	V_ACT	=	480;
	parameter	V_BLANK	=	V_FRONT+V_SYNC+V_BACK;
	parameter	V_TOTAL	=	V_FRONT+V_SYNC+V_BACK+V_ACT;
	////////////////////////////////////////////////////////////
	assign	oVGA_SYNC	=	1'b1;			//	This pin is unused.
	assign	oVGA_BLANK	=	~((H_Cont<H_BLANK)||(V_Cont<V_BLANK));
	assign	oVGA_CLOCK	=	~iCLK;
	assign	oVGA_R		=	iRed;
	assign	oVGA_G		=	iGreen;
	assign	oVGA_B		=	iBlue;
	assign	oAddress	=	oCurrent_Y*H_ACT+oCurrent_X;
	assign	oRequest	=	((H_Cont>=H_BLANK && H_Cont<H_TOTAL)	&&
							 (V_Cont>=V_BLANK && V_Cont<V_TOTAL));
	assign	oCurrent_X	=	(H_Cont>=H_BLANK)	?	H_Cont-H_BLANK	:	11'h0	;
	assign	oCurrent_Y	=	(V_Cont>=V_BLANK)	?	V_Cont-V_BLANK	:	11'h0	;

	//	Horizontal Generator: Refer to the pixel clock
	always@(posedge iCLK or negedge iRST_N)
	begin
		if(!iRST_N)
		begin
			H_Cont		<=	0;
			oVGA_HS		<=	1;
		end
		else
		begin
			if(H_Cont<H_TOTAL)
			H_Cont	<=	H_Cont+1'b1;
			else
			H_Cont	<=	0;
			//	Horizontal Sync
			if(H_Cont==H_FRONT-1)			//	Front porch end
			oVGA_HS	<=	1'b0;
			if(H_Cont==H_FRONT+H_SYNC-1)	//	Sync pulse end
			oVGA_HS	<=	1'b1;
		end
	end

	//	Vertical Generator: Refer to the horizontal sync
	always@(posedge oVGA_HS or negedge iRST_N)
	begin
		if(!iRST_N)
		begin
			V_Cont		<=	0;
			oVGA_VS		<=	1;
		end
		else
		begin
			if(V_Cont<V_TOTAL)
			V_Cont	<=	V_Cont+1'b1;
			else
			V_Cont	<=	0;
			//	Vertical Sync
			if(V_Cont==V_FRONT-1)			//	Front porch end
			oVGA_VS	<=	1'b0;
			if(V_Cont==V_FRONT+V_SYNC-1)	//	Sync pulse end
			oVGA_VS	<=	1'b1;
		end
	end

endmodule





//==== Shadow Realm ===\\


//		//=== Drawing Bullet ===\\
//		if(shootButton == 1'b1)begin
//			shootFlag = 1;
//		end
//		if(shootFlag == 1 && shootButton == 0)begin
//			bulletExist = 1;
//			snapshotx1 = ship_hull_x1;
//			shapshoty1 = ship_hull_y1;
//		end
//		if( (bulletExist == 1) && (VGA_X >= snapshotx1 + 5) && (VGA_X <= snapshotx1 + 7) && (VGA_Y >= shapshoty1 - bullety - 12) && (VGA_Y <= shapshoty1 - bullety - 6) )begin
//			mRed = en_red;
//			mGreen = en_green;
//			mBlue = en_blue;
//		end



//		//=== Shoot Timer and Movement for Shot ===\\
//		if(bulletExist == 1) begin
//			shootTimer = shootTimer + 1;
//			if(shootTimer == 1250000/4)begin
//				shootTimer = 0;
//				bullety = bullety + 1;
//				if(bullety == 400)begin
//					bullety = 0;
//					bulletExist = 0;
//				end
//			end
//		end
		//=========================================\\
		
		
//		
//		if(xFlag[0] && key[0]==0)begin
//			eox = eox + 1;
//			xFlag[0] = 0;
//		end
		//======================\\
		

		//making movement
//		quarter = quarter + 1'b1;
//		
//		//if(pause == 1'b0) begin
//			//add offset to a shape to move it back and forth.
//			//12,500,000 MHz is 1/4 a second
//			if(quarter == 12500000/16) begin
//				quarter = 0;
//				offset = direction ? offset + 1 : offset - 1;
//				//offset = offset + 1;
//				moveCounter = moveCounter + 1;
//				if(moveCounter == 420) begin
//					moveCounter = 0;
//					//offset = offset - 1;
//					direction = !direction;
//				end
//			end
//		//end
//		
