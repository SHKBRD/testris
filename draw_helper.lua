function draw_blob(x,y,w,h,rad,col)
	w=max(w,rad*2)
	h=max(h,rad*2)
	
	xrad=x+rad
	yrad=y+rad
	xw=x+w
	yh=y+h
	xwrad=xw-rad
	yhrad=yh-rad
	
	circfill(xrad,yrad,rad,col)
	circfill(xwrad,yrad,rad,col)
	circfill(xrad,yhrad,rad,col)
	circfill(xwrad,yhrad,rad,col)
	rectfill(xrad,y,xwrad,yh,col)
	rectfill(x,yrad,xw,yhrad,col)
end
