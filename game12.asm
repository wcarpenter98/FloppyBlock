stack segment para stack
	DB 64 dup(' ')
stack ends

data segment para 'data'
	window_height DW 140h ;the width of the window (320 pixels)
	window_width DW 0C8h ;the height of the window (200 pixels)
	time_aux DB 0 ;stores previous time
	
	;teamcode
	startGame_text1 DB 'Welcome to Flappy Box','$'
	startGame_text2 DB ' Tap space to flap','$'
	gameOver_text DB 'Game over', '$'
	
	block_size DW 09h
	
	block_velocity_forward DW 05h
	block_velocity_x DW 05h
	block_velocity_y DW 05h
	
	block_jump_x DW 02h
	block_jump_y DW 05h
	
	bar_small_x DW 0beh
	bar_small_y DW 0b3h
	
	bar_medium_x DW 078h   ; X initial position (column) of the bar
	bar_medium_y DW 0a9h   ; Y initial position (row) of the bar 
	
	bar_tall_x DW 0118h
	bar_tall_y DW 02Dh		;obstacle y initial position
	
	bar_tallTwo_x DW 0B4h
	bar_tallTwo_y DW 02Dh
	
	bar_tallThree_x DW 050h
	bar_tallThree_y DW 02Dh
	
	bar_small_height DW 14h
	bar_small_width DW 09h
	
	bar_medium_height DW 01eh
	bar_tall_height DW 040h  ;height of obstacle
	
	bar_tallTwo_height DW 040h 
	
	bar_tallThree_height DW 040h
	
	string_total_time DB '0','$'
	
	total_points DB 0
	
	
	;team code
	
	obstacleOneX DW 0B4H ; x position of the block
	obstacleOneY DW 096H ; x position of the block
	obstacleOneSize DW 09h
	
	
	squareOneX DW 19H ;x position of the block
	squareOneY DW 096h ;y position of the block 
	
	squareTwoX DW 032H ;x position of the block
	squareTwoY DW 096h ;y position of the block 
	
	squareThreeX DW 4BH ;x position of the block
	squareThreeY DW 096h ;y position of the block 
	
	coverSquareX DW 19h
	coverSquareY DW 096h ;y position of the block 
	previousTimeInSeconds DB 0
	
	delayCounter DW 00h
	
	coverSquareSize DW 096h
	squareSize DW 09h
data ends

code segment para 'code'

	main proc far
	Assume cs:code,ds:data,ss:stack ;Assume code, data, and stack segment register
	push ds
	sub ax, ax
	push ax
	mov ax, data
	mov ds, ax
	pop ax
	pop ax
	

	call videoMode
	call startScreen
	call spawnSquare
	;call spawnObstacleOne
	call drawTall
	call scoreBoard
	spawnSetter:;"main loop"

	;spawnBlocks:
		;call spawnSquare
	
	;if spacebar is pressed, then jump the block, if it isnt pressed, move the block downward
	Read:
		mov ah,01h						;check keyboard status
		int 16h			
		jnz clear
	;if not pressed, continue to drop block
	jmp secondDelay
	

	clear:
		cmp al,20h				;see if space was pressed
		mov ah, 00h
		je jumpAnimation			;if pressed, jump block
		

	jumpAnimation:
		mov ah, 00h
		int 16h
		call jumpSquare
	
	jmp secondDelay

	noclear:
		mov ah, 00h
		int 16h
		jmp secondDelay
	
	secondDelay:
		mov ah, 2ch ; get system time in seconds
		int 21h
		cmp dl, previousTimeInSeconds ;dh = 1 sec     dl = 1/100 of a sec
		je secondDelay ;if the time has not updated its second counter, try to gather it again and
		mov previousTimeInSeconds, dh
	;forgive me for i am about to sin
	call scoreBoard
	call customDelay2
	call dropSquare
	call moveTallObstacle
	call moveTallTwoObstacle
	call moveTallThreeObstacle
	call updateScoreBoard
	jmp spawnSetter

	gameOverLabel:
		call gameOver


	ret
	main endp
	

	customDelay proc near
		mov cx, delayCounter
		delayLooper:
		call delay
		inc delayCounter
		cmp delayCounter, 180h ;this will tune the delay => higher number, bigger delay 180h is default
		je break
		loop delayLooper
	break:
	mov delayCounter, 00h
	ret
	customDelay endp
	
	
	
	customDelay2 proc near
	;im so sorry for this
	call customDelay
	call customDelay
	call customDelay
	ret
	customDelay2 endp

	delay proc near
		delayLabel:
		mov ah, 2ch ; get system time in seconds
		int 21h
		cmp dl, previousTimeInSeconds ;dh = 1 sec     dl = 1/100 of a sec
		je delayLabel ;if the time has not updated its second counter, try to gather it again and
		mov previousTimeInSeconds, dh
	ret
	delay endp
	
	jumpSquare proc near
		;space bar was pressed to get this function call
		;hide old square
		call changeSpawnSquareColor
		;now increment the y and then redraw the square
		mov cx, 12h
		mov dx, squareOneY
		sub dx, cx
		mov squareOneY, dx
		call spawnSquare
	ret 
	jumpSquare endp


	dropSquare proc near
		;space bar was pressed to get this function call
		;hide old square
		call changeSpawnSquareColor
		;now increment the y and then redraw the square
		mov cx, 04h
		mov dx, squareOneY
		add dx, cx
		mov squareOneY, dx
		call spawnSquare
	ret 
	dropSquare endp
	

	spawnSquare proc near
		mov cx, squareOneX
		mov dx, squareOneY
		spawnOne:
			mov ah, 0ch	;write graphics pixel
			mov al, 04h	;red square
			mov bh, 00h	;set page number
			int 10h
			inc cx
			mov ax, cx
			sub ax, squareOneX
			cmp ax, squareSize
			jng spawnOne
			mov cx, squareOneX
			inc dx
			mov ax,dx
			sub ax, squareOneY
			cmp ax, squareSize
			jng spawnOne
	ret
	spawnSquare endp
	
	
	;essentially just redraws the square to the color of the background so it disappears
	changeSpawnSquareColor proc near
		mov cx, squareOneX
		mov dx, squareOneY
		spawnTwo:
			mov ah, 0ch	;write graphics pixel
			mov al, 00h	;black square
			mov bh, 00h	;set page number
			int 10h
			inc cx
			mov ax, cx
			sub ax, squareOneX
			cmp ax, squareSize
			jng spawnTwo
			mov cx, squareOneX
			inc dx
			mov ax,dx
			sub ax, squareOneY
			cmp ax, squareSize
			jng spawnTwo
	ret
	changeSpawnSquareColor endp



	spawnObstacleOne proc near
		mov cx, obstacleOneX
		mov dx, obstacleOneY
		spawnObstacleLoopOne:
			mov ah, 0ch	;write graphics pixel
			mov al, 04h	;red square
			mov bh, 00h	;set page number
			int 10h
			inc cx
			mov ax, cx
			sub ax, obstacleOneX
			cmp ax, obstacleOneSize
			jng spawnObstacleLoopOne
			mov cx, obstacleOneY
			inc dx
			mov ax,dx
			sub ax, obstacleOneY
			cmp ax, obstacleOneSize
			jng spawnObstacleLoopOne
	ret
	spawnObstacleOne endp


;team code
	drawSmall proc near
		mov cx, bar_small_x
		mov dx, bar_small_y
		
		drawSmall_horizontal:
			mov ah, 0ch	;set config
			mov al, 07h	;set color
			mov bh, 00h	;set page number
			int 10h
			
			inc cx
			mov ax, cx
			sub ax, bar_small_x
			cmp ax, bar_small_width
			jng drawSmall_horizontal
			
			mov cx, bar_small_x
			inc dx
			
			mov ax,dx
			sub ax, bar_small_y
			cmp ax, bar_small_height
			jng drawSmall_horizontal
			
		ret
	drawSmall endp 
	
	drawMedium proc near
		mov cx, bar_medium_x
		mov dx, bar_medium_y
		
		drawMedium_horizontal:
			mov ah, 0ch	;set config
			mov al, 07h	;set color
			mov bh, 00h	;set page number
			int 10h
			
			inc cx               ;cx = cx+1
			mov ax, cx           
			sub ax, bar_medium_x
			cmp ax, bar_small_width
			jng drawMedium_horizontal
			
			mov cx, bar_medium_x
			inc dx
			
			mov ax,dx
			sub ax, bar_medium_y
			cmp ax, bar_medium_height
			jng drawMedium_horizontal
		
	
		ret
	drawMedium endp
	
	drawTall proc near 
		mov cx, bar_tall_x
		mov dx, bar_tall_y
		drawTall_horizontal:
			mov ah, 0ch	;set config
			mov al, 0Fh	;set color
			mov bh, 00h	;set page number
			int 10h
			inc cx               ;cx = cx+1
			mov ax, cx           
			sub ax, bar_tall_x
			cmp ax, bar_small_width
			jng drawTall_horizontal ;reached the invisible wall on the right side of the square    ------>|
			;here it drops down the y axis 1 pixel
			mov cx, bar_tall_x
			inc dx
			mov ax,dx
			sub ax, bar_tall_y
			cmp ax, bar_tall_height
			jng drawTall_horizontal
			call checkColision
		ret 
	drawTall endp


;team code





	drawTallTwo proc near 
		mov cx, bar_tallTwo_x
		mov dx, bar_tallTwo_y
		drawTallTwo_horizontal:
			mov ah, 0ch	;set config
			mov al, 0Fh	;set color
			mov bh, 00h	;set page number
			int 10h
			inc cx               ;cx = cx+1
			mov ax, cx           
			sub ax, bar_tallTwo_x
			cmp ax, bar_small_width
			jng drawTallTwo_horizontal
			mov cx, bar_tallTwo_x
			inc dx
			mov ax,dx
			sub ax, bar_tallTwo_y
			cmp ax, bar_tallTwo_height
			jng drawTallTwo_horizontal

		ret 
	drawTallTwo endp
	
	drawTallThree proc near 
		mov cx, bar_tallThree_x
		mov dx, bar_tallThree_y
		drawTallThree_horizontal:
			mov ah, 0ch	;set config
			mov al, 0Fh	;set color
			mov bh, 00h	;set page number
			int 10h
			inc cx               ;cx = cx+1
			mov ax, cx           
			sub ax, bar_tallThree_x
			cmp ax, bar_small_width
			jng drawTallThree_horizontal
			mov cx, bar_tallThree_x
			inc dx
			mov ax,dx
			sub ax, bar_tallThree_y
			cmp ax, bar_tallThree_height
			jng drawTallThree_horizontal
		
		ret 
	drawTallThree endp
	
	
	checkColision proc near
		mov ah,0Dh
		mov cx,squareOneX
		add cx, squareSize ;the x axis we are checking
		add cx, 1
		mov dx, squareOneY
		sub ax, squareSize
		int 10H ; AL = COLOR
		cmp al, 0Fh ;is the pixel to the direct right of the player square sprite a white block like the obstacle?
		jne missed
		jmp gameOverLabel
		missed:
	ret
	checkColision endp

;zach
	;essentially just redraws the obstacle from drawTall to the color of the background so it disappears
	changeTallColor proc near
		mov cx, bar_tall_x
		mov dx, bar_tall_y
		drawTall_horizontalColor:
			mov ah, 0ch	;set config
			mov al, 00h	;set color
			mov bh, 00h	;set page number
			int 10h
			inc cx               ;cx = cx+1
			mov ax, cx           
			sub ax, bar_tall_x
			cmp ax, bar_small_width
			jng drawTall_horizontalColor
			mov cx, bar_tall_x
			inc dx
			mov ax,dx
			sub ax, bar_tall_y
			cmp ax, bar_tall_height
			jng drawTall_horizontalColor
		ret 
	changeTallColor endp
	
	changeTallTwoColor proc near
		mov cx, bar_tallTwo_x
		mov dx, bar_tallTwo_y
		drawTallTwo_horizontalColor:
			mov ah, 0ch	;set config
			mov al, 00h	;set color
			mov bh, 00h	;set page number
			int 10h
			inc cx               ;cx = cx+1
			mov ax, cx           
			sub ax, bar_tallTwo_x
			cmp ax, bar_small_width
			jng drawTallTwo_horizontalColor
			mov cx, bar_tallTwo_x
			inc dx
			mov ax,dx
			sub ax, bar_tallTwo_y
			cmp ax, bar_tallTwo_height
			jng drawTallTwo_horizontalColor
		ret 
	changeTallTwoColor endp
	
	changeTallThreeColor proc near
		mov cx, bar_tallThree_x
		mov dx, bar_tallThree_y
		drawTallThree_horizontalColor:
			mov ah, 0ch	;set config
			mov al, 00h	;set color
			mov bh, 00h	;set page number
			int 10h
			inc cx               ;cx = cx+1
			mov ax, cx           
			sub ax, bar_tallThree_x
			cmp ax, bar_small_width
			jng drawTallThree_horizontalColor
			mov cx, bar_tallThree_x
			inc dx
			mov ax,dx
			sub ax, bar_tallThree_y
			cmp ax, bar_tallThree_height
			jng drawTallThree_horizontalColor
		ret 
	changeTallThreeColor endp

	moveTallObstacle proc near
		;space bar was pressed to get this function call
		;hide old square
		call changeTallColor
		;now increment the x and then redraw the square
		mov cx, 09h
		mov dx, bar_tall_x
		sub dx, cx
		mov bar_tall_x, dx
		mov cx, 01h
		mov dx, bar_tall_y
		sub dx, cx
		mov bar_tall_y, dx
		call drawTall
		
	ret 
	moveTallObstacle endp

	moveTallTwoObstacle proc near
		;space bar was pressed to get this function call
		;hide old square
		call changeTallTwoColor
		;now increment the x and then redraw the square
		mov cx, 09h
		mov dx, bar_tallTwo_x
		sub dx, cx
		mov bar_tallTwo_x, dx
		mov cx, 02h
		mov dx, bar_tallTwo_y
		sub dx, cx
		mov bar_tallTwo_y, dx
		call drawTallTwo
	ret 
	moveTallTwoObstacle endp

	moveTallThreeObstacle proc near
		;space bar was pressed to get this function call
		;hide old square
		call changeTallThreeColor
		;now increment the x and then redraw the square
		mov cx, 09h
		mov dx, bar_tallThree_x
		sub dx, cx
		mov bar_tallThree_x, dx
		mov cx, 01h
		mov dx, bar_tallThree_y
		sub dx, cx
		mov bar_tallThree_y, dx
		call drawTallThree
	ret 
	moveTallThreeObstacle endp
	

	
	
;zach



	videoMode proc near              ;clear the screen by restarting the video mode
		mov ah,00h                   ;set the configuration to video mode
		mov al,13h                   ;choose the video mode
		int 10h    					 ;execute the configuration 
		mov ah,0Bh 					 ;set the configuration
		mov bh,00h 					 ;to the background color
		mov bl,00h 					 ;choose black as background color
		int 10h    					 ;execute the configuration
		ret
	videoMode endp
	
	startScreen proc near
		mov ah,02h						;set cursor position
		mov bh,00h						;set page number
		mov dh,10						;set row
		mov dl,50						;set column
		int 10h
		mov ah,09h                      ;WRITE STRING TO STANDARD OUTPUT
		lea dx, startGame_text1      	;give DX a pointer to the string 
		int 21h 						;print the string
		
		mov ah,02h						;set cursor position
		mov bh,00h						;set page number
		mov dh,13						;set row
		mov dl,50						;set column
		int 10h
		mov ah,09h                      ;WRITE STRING TO STANDARD OUTPUT
		lea dx, startGame_text2      	;give DX a pointer to the string 
		int 21h 						;print the string
		
		Readx:
		mov ah,01h						;check keyboard status
		int 16h							
		cmp al,20h						;see if shift was pressed
		je Clearx						;if pressed, clear screen
		jmp Readx						;if not pressed, read again
		
		Clearx:
		call videoMode
		
		ret
	startScreen endp
	
	
	gameOver proc near
		call videoMode               ;clear the screen before displaying the menu

		mov ah,02h						;set cursor position
		mov bh,00h						;set page number
		mov dh,10						;set row
		mov dl,50						;set column
		int 10h
		
		mov ah,09h                      ;WRITE STRING TO STANDARD OUTPUT
		lea dx, gameOver_text      	;give DX a pointer to the string 
		int 21h 						;print the string
		ret
	gameOver endp
	
	scoreBoard proc near
		mov ah,02h						;set cursor position
		mov bh,00h						;set page number
		mov dh,10						;set row
		mov dl,1Fh					;set column
		int 10h
		
		mov ah,09h                      ;WRITE STRING TO STANDARD OUTPUT
		lea dx, string_total_time     	;give DX a pointer to the string 
		int 21h 						;print the string
		
		ret
	scoreBoard endp
	
	updateScoreBoard proc near
		xor ax, ax
		inc total_points
		mov al, total_points
		add al, 30h
		mov [string_total_time], al
		
		ret
	ret
	updateScoreBoard endp
	
	
code ends
end