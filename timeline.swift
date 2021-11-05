class scene_timeline {
    /** Constants*/
    let timeline_view_start_distance = 10.0;
    let timeline_view_mimimum_ruler_unit_distance = 10.0;
    let timeline_view_possible_ruler_unit_distances=[5,10,25,50,100,250,500,1000,2500,5000,10000,30000,60000];
    
    /** Variables*/
    var time_scale = 0.5 //scale in milliseconds per pixel
    var time_total = 3600000.0 //in milliseconds
    var scene_timeline_object_array:[scene_timeline_object]=[]
    
    /** Views */
    
    let timeline = NSScrollView(frame: NSRect(x: 300, y: 300, width: 600, height: 240))
    let clipView = NSClipView()
    let documentView = NSView(frame: NSRect(x: 0, y: 0, width: 1200, height: 330))
    let object_info_column = NSView(frame: NSRect(x: 0, y: 0, width: 100, height: 300))
    let time_info_column = NSView(frame: NSRect(x: 0, y: 0, width: 100, height: 30))
    let timeline_ruler_view = NSView(frame: NSRect(x: 100, y: 300, width: 1200, height: 30))
    
    /**Internal Classes**/
    class scene_timeline_object : NSObject {
        let timeline_object = NSView(frame: NSRect(x: 0, y: 0, width: 1200, height: 60));
        var x=0;
        var y=0;
        func initialize(x: CGFloat, y: CGFloat) -> NSView{
            timeline_object.translatesAutoresizingMaskIntoConstraints = false
            timeline_object.wantsLayer = true
            timeline_object.layer?.backgroundColor = NSColor.init(red: (50.0/255),green:(49.0/255),blue: (49.0/255), alpha: 1.0).cgColor
            timeline_object.layer?.borderWidth = 1
            timeline_object.layer?.borderColor = NSColor.gray.cgColor
            timeline_object.frame.origin.x=x
            timeline_object.frame.origin.y=y
            return timeline_object;
        }
    }
    
    /**Timeline Object Functions**/
    func scene_timeline_objects_draw() {
        var counter : Int = 0;
        let scene_timeline_object_num: CGFloat = CGFloat(scene_timeline_object_array.count);
        documentView.frame.size.height = (60.0*(scene_timeline_object_num))+timeline_ruler_view.frame.height;
        object_info_column.frame.size.height = (60.0*(scene_timeline_object_num));
        scene_timeline_object_array.reversed().forEach{ scene_timeline_object_element in
            documentView.addSubview(scene_timeline_object_element.initialize(x: object_info_column.frame.width, y: CGFloat((counter*60))));
            counter+=1;
        }
        
    }
    func scene_timeline_objects_draw_refresh() {
        scene_timeline_object_array.reversed().forEach{ scene_timeline_object_element in
            scene_timeline_object_element.timeline_object.frame.size.width=time_total/time_scale + timeline_view_start_distance;
        }
        
    }
    func scene_timeline_object_add() {
        scene_timeline_object_array.append(scene_timeline_object());
    }
    
    /**Timeline Ruler Functions**/
    func timeline_view_ruler_draw(){
        timeline_ruler_view.wantsLayer = true
        timeline_ruler_view.layer?.backgroundColor=NSColor.black.cgColor
        timeline_ruler_view.alphaValue=0.7
        
        let layer_main_unit_scale = CAShapeLayer();
        let path = CGMutablePath();
        
        layer_main_unit_scale.contentsScale=NSScreen.main?.backingScaleFactor ?? 1;
        layer_main_unit_scale.strokeColor = NSColor.white.cgColor
        
        timeline_ruler_view.frame.size.width=(time_total/time_scale)+object_info_column.frame.width + timeline_view_start_distance;
        documentView.frame.size.width=(time_total/time_scale)+object_info_column.frame.width + timeline_view_start_distance;
        
        /* Remove all Layers */
        timeline_ruler_view.layer?.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        
        
        var current_distance_index = 0;
        while (Double(timeline_view_possible_ruler_unit_distances[current_distance_index])/time_scale < timeline_view_mimimum_ruler_unit_distance){
            current_distance_index+=1;
        }
        
        let distance=Double(timeline_view_possible_ruler_unit_distances[current_distance_index])/time_scale;
        let current_location=clipView.bounds.origin.x.truncatingRemainder(dividingBy: distance);
        let current_location_text=clipView.bounds.origin.x.truncatingRemainder(dividingBy: distance*5);
        
        stride(from: clipView.bounds.origin.x-current_location_text, to: CGFloat(clipView.bounds.origin.x+clipView.frame.width), by: 5*distance).forEach {
            
            point in
            path.move(to: CGPoint(x: timeline_view_start_distance+point, y: 0));
            path.addLine(to: CGPoint(x: timeline_view_start_distance+point, y:15));
            
            
            
            let unit_numbers_text_layer=CATextLayer();
            unit_numbers_text_layer.contentsScale=NSScreen.main?.backingScaleFactor ?? 1;
            unit_numbers_text_layer.frame=CGRect(x: timeline_view_start_distance+point-20, y: 17, width: 50, height: 13)
            unit_numbers_text_layer.fontSize=12.0;
            unit_numbers_text_layer.opacity=1;
            unit_numbers_text_layer.alignmentMode=CATextLayerAlignmentMode.center
            unit_numbers_text_layer.anchorPoint=NSPoint(x:0.5,y:0.5);
            
            var zahl=Double(Int(point/distance)*timeline_view_possible_ruler_unit_distances[current_distance_index]);
            var einheit="ms";
            if (zahl>=1000){
                zahl = zahl/1000;
                einheit="s";
                if (zahl>=600){
                    zahl = zahl/60;
                    einheit="m";
                    
                }
            }
            if (einheit=="ms"){
                unit_numbers_text_layer.string=String(format:"%.0f"+einheit,zahl);
            }else{
                unit_numbers_text_layer.string=String(format:"%.2f"+einheit,zahl);
            }
            timeline_ruler_view.layer?.addSublayer(unit_numbers_text_layer);
        }
        
        layer_main_unit_scale.lineWidth=2;
        layer_main_unit_scale.path=path;
        timeline_ruler_view.layer?.addSublayer(layer_main_unit_scale);
        
        
        let layer_sub_unit_scale = CAShapeLayer()
        let path_sub_unit_scale = CGMutablePath()
        
        layer_sub_unit_scale.strokeColor = NSColor.white.cgColor
        
        stride(from: clipView.bounds.origin.x-current_location, to: CGFloat(clipView.bounds.origin.x+clipView.frame.width), by: distance).forEach {
            point in
            
            path_sub_unit_scale.move(to: CGPoint(x: timeline_view_start_distance+point, y: 0))
            path_sub_unit_scale.addLine(to: CGPoint(x: timeline_view_start_distance+point, y:10))
            
        }
        layer_sub_unit_scale.lineWidth=1
        layer_sub_unit_scale.path=path_sub_unit_scale
        timeline_ruler_view.layer?.addSublayer(layer_sub_unit_scale)
    }
    
    /**Time Info Functions**/
    private func get_current_time_from_point (point: Double) -> Double{
        let current_time=Double(clipView.bounds.origin.x + point)*time_scale;
        return current_time
    }
    private func time_info_column_draw (absolute_position: NSPoint){
        time_info_column.layer?.sublayers?.forEach { $0.removeFromSuperlayer() };
        
        time_info_column.wantsLayer = true
        time_info_column.layer?.backgroundColor = NSColor.init(red:(37/255), green:(37/255), blue:(35/255), alpha: 1).cgColor //
                                                                                                                              // time_info_column.frame.origin.y=documentView.frame.maxY-time_info_column.frame.height
        
        var mouse_position = NSPoint(x: 0, y: 0);
        mouse_position = absolute_position;
        mouse_position.x -= (timeline.frame.origin.x + timeline_ruler_view.frame.minX + timeline_view_start_distance);
        mouse_position.x = (mouse_position.x>=0) ? mouse_position.x : 0;
        
        let current_time=get_current_time_from_point(point: mouse_position.x);
        
        let time_info_column_text_layer=CATextLayer();
        time_info_column_text_layer.contentsScale=NSScreen.main?.backingScaleFactor ?? 1;
        time_info_column_text_layer.frame=CGRect(x: 0, y: 0, width: 100, height: 30);
        time_info_column_text_layer.string=String(format:"%.0f",current_time);
        time_info_column_text_layer.fontSize=12.0;
        time_info_column_text_layer.opacity=1;
        time_info_column_text_layer.alignmentMode=CATextLayerAlignmentMode.center;
        time_info_column_text_layer.anchorPoint=NSPoint(x:0.5,y:0.5);
        time_info_column.layer?.addSublayer(time_info_column_text_layer);
        
    }
    
    /**View Init Functions**/
    func timeline_scrollview_init(){
        timeline.translatesAutoresizingMaskIntoConstraints = false
        timeline.borderType = .bezelBorder
        timeline.backgroundColor = NSColor.gray
        timeline.hasVerticalScroller = true
        timeline.hasHorizontalScroller = true
        timeline.frame.origin.x=300
        timeline.frame.origin.y=300
        
        timeline.contentView = clipView
        clipView.backgroundColor = NSColor.blue
        documentView.wantsLayer = true
        timeline.documentView = documentView
        documentView.layer?.backgroundColor = NSColor.red.cgColor
        documentView.layer?.borderWidth = 0
        documentView.layer?.borderColor = NSColor.darkGray.cgColor
        clipView.scaleUnitSquare(to: NSSize(width: 1, height: 1))
        clipView.postsBoundsChangedNotifications = true
    }
    func add_callbacks(){
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(startscroll),
                                               name: NSScrollView.willStartLiveScrollNotification,
                                               object: self.timeline)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(endscroll),
                                               name: NSScrollView.didEndLiveScrollNotification,
                                               object: self.timeline)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(scrolled),
                                               name: NSScrollView.boundsDidChangeNotification,
                                               object: self.clipView)
        
        NSEvent.addLocalMonitorForEvents(matching: NSEvent.EventTypeMask.magnify, handler: magnify_event);
        NSEvent.addLocalMonitorForEvents(matching: NSEvent.EventTypeMask.mouseMoved, handler: mouse_event);
    }
    func  object_info_column_draw(){
        
        object_info_column.translatesAutoresizingMaskIntoConstraints = false
        object_info_column.wantsLayer = true
        let shadow=NSShadow();
        shadow.shadowColor=NSColor.green
        shadow.shadowOffset=NSMakeSize(0, 0)
        shadow.shadowBlurRadius=10
        object_info_column.shadow=shadow
        object_info_column.layer?.backgroundColor = NSColor.init(red:(37/255), green:(37/255), blue:(35/255), alpha: 1).cgColor //
        object_info_column.layer?.borderWidth = 1
        object_info_column.layer?.borderColor = NSColor.gray.cgColor
    }
    func initialize() -> NSScrollView{
        timeline_scrollview_init();
        add_callbacks();
        
        scene_timeline_object_add();
        scene_timeline_object_add();
        scene_timeline_object_add();
        scene_timeline_object_add();
        scene_timeline_object_add();
        scene_timeline_object_add();
        scene_timeline_object_add();
        
        scene_timeline_objects_draw();
        scene_timeline_objects_draw_refresh();
        object_info_column_draw();
        timeline_view_ruler_draw();
        time_info_column_draw(absolute_position: time_info_column.window?.convertPoint(fromScreen: NSEvent.mouseLocation) ?? NSPoint(x: 0, y: 0));
        
        documentView.addSubview(timeline_ruler_view)
        documentView.addSubview(object_info_column)
        documentView.addSubview(time_info_column);
        timeline.scroll(clipView, to: NSPoint(x: 0,y: documentView.frame.maxY))
        return self.timeline
    }
    
    /** Event Callbacks*/
    /** Scroll event Callbacks*/
    private func mouse_event(_ event: NSEvent) -> NSEvent? {
        
        if(NSPointInRect(event.locationInWindow, timeline.frame)){
            time_info_column_draw(absolute_position: event.locationInWindow);
        }
        return event;
    }
    private func magnify_event(_ event: NSEvent) -> NSEvent? {
        
        if(NSPointInRect(event.locationInWindow, self.timeline.frame)){
            //time_info_column_draw(absolute_position: event.locationInWindow);
            let magnification_factor=(-1.0)*event.magnification;
            time_scale+=magnification_factor*time_scale;
            if(time_scale<0.5){
                time_scale=0.5;
            }
            if(time_scale>1200){
                time_scale=1200;
            }
            
            timeline_view_ruler_draw();
            time_info_column_draw(absolute_position: time_info_column.window?.convertPoint(fromScreen: NSEvent.mouseLocation) ?? NSPoint(x: 0, y: 0));
            scene_timeline_objects_draw_refresh();
        }
        return event;
    }
    @objc func startscroll() {
        /*This is done to fix jumping while the animation takes place and the user decides to change scroll again*/
        timeline.contentView.setBoundsOrigin(NSMakePoint(timeline.contentView.bounds.origin.x, timeline.contentView.bounds.origin.y))
    }
    @objc func endscroll() {
        /*Checks if scrolled area is within boundy - then animates to move to the next complete element*/
        if(timeline.contentView.bounds.origin.y>0 && timeline.contentView.bounds.origin.y<=(timeline.documentView?.frame.height ?? 0-timeline.contentView.frame.height)-1){
            var offset = timeline.contentView.bounds.origin.y
            offset = round(offset / scene_timeline_object_array[0].timeline_object.frame.height) *  scene_timeline_object_array[0].timeline_object.frame.height;
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 1
                timeline.contentView.animator().setBoundsOrigin(NSMakePoint(timeline.contentView.bounds.origin.x, offset))
            }) {
            }}
    }
    @objc func scrolled(_ event: NSEvent) -> NSEvent?{
        object_info_column.frame.origin.x=timeline.contentView.bounds.origin.x
        timeline_ruler_view.frame.origin.y=timeline.contentView.bounds.origin.y+timeline.contentView.frame.height-timeline_ruler_view.frame.height
        time_info_column.frame.origin.y=timeline.contentView.bounds.origin.y+timeline.contentView.frame.height-time_info_column.frame.height
        time_info_column.frame.origin.x=timeline.contentView.bounds.origin.x
        timeline_view_ruler_draw();
        
        time_info_column_draw(absolute_position: time_info_column.window?.convertPoint(fromScreen: NSEvent.mouseLocation) ?? NSPoint(x: 0, y: 0));
        return event;
    }
    /** End of Scroll Event Callbacks*/
    /** End of Event Callbacks*/
}
