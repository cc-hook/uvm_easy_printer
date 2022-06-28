`include "uvm_easy_printer.sv"
///////////////////////////////////////////
typedef enum {
  RED=0,
  BLUE=1,
  GREEN=2
} color;

class c1 extends uvm_sequence_item;
	rand color    theme;
	rand bit[3:0] addr;

	`uvm_object_utils_begin(c1)
		`uvm_field_int(addr,UVM_PRINT)
		`uvm_field_enum(color,theme,UVM_PRINT)
	`uvm_object_utils_end

	function new(string name="c1");
		super.new(name);
	endfunction

	//virtual function void do_print(uvm_printer printer);
	//	super.do_print(printer);
	//endfunction
endclass

class c2 extends uvm_sequence_item ;
	rand bit[15:0] data;
	rand bit[3:0]  field_sarray[4];
	rand bit[3:0]  field_queue[$];
	string 		   m_name;
	rand c1			   c1_obj;
	c1			   obj_queue[$];

	`uvm_object_utils_begin(c2)
		`uvm_field_int(data,UVM_PRINT)
		`uvm_field_string(m_name,UVM_PRINT)
		`uvm_field_object(c1_obj,UVM_PRINT)
		`uvm_field_sarray_int(field_sarray,UVM_PRINT)
		`uvm_field_queue_int(field_queue,UVM_PRINT)
		`uvm_field_queue_object(obj_queue,UVM_PRINT)
	`uvm_object_utils_end

	constraint c_field_queue {
		field_queue.size()==8;
	}

	function new(string name="c2");
		super.new(name);
		m_name="uvm_easy_printer";
		c1_obj = new();
		for(int i=0;i<3;i++) obj_queue[i]=new();
	endfunction

	//virtual function void do_print(uvm_printer printer);
	//	super.do_print(printer);
	//endfunction
endclass


program tb_top;
	c2 obj;
	uvm_printer json_printer=uvm_hybrid_printer::create_printer(uvm_hybrid_printer::JSON_PRINTER);
	uvm_printer yaml_printer=uvm_hybrid_printer::create_printer(uvm_hybrid_printer::YAML_PRINTER);
	uvm_printer xml_printer =uvm_hybrid_printer::create_printer(uvm_hybrid_printer::XML_PRINTER);
	uvm_printer table_printer =uvm_hybrid_printer::create_printer(uvm_hybrid_printer::TABLE_PRINTER);
	uvm_printer tree_printer =uvm_hybrid_printer::create_printer(uvm_hybrid_printer::TREE_PRINTER);
	//easy_printer.set_radix_string(UVM_HEX,"0x");
	//uvm_table_printer uvm_default_table_printer = new();
	//uvm_tree_printer uvm_default_tree_printer  = new();
	//uvm_line_printer uvm_default_line_printer  = new();
	initial begin
		obj = new();
		obj.randomize();
		foreach(obj.obj_queue[i]) begin
			obj.obj_queue[i].randomize();
		end
		//obj.print();
		//uvm_default_printer = uvm_default_tree_printer;
		//obj.print();
		//uvm_default_printer = uvm_default_line_printer;
		$display("json_printer test......");
		uvm_default_printer = json_printer;
		obj.print();

		$display("yaml_printer test......");
		uvm_default_printer = yaml_printer;
		obj.print();

		$display("table_printer test......");
		uvm_default_printer = table_printer;
		obj.print();

		$display("tree_printer test......");
		uvm_default_printer = tree_printer;
		obj.print();

		$display("xml_printer test......");
		uvm_default_printer = xml_printer;
		obj.print();
		//$display("X1:%s",obj.sprint(easy_printer));
		//$display("X2:%s",obj.sprint(easy_printer));
	end
endprogram
//class uvm_easy_printer extends uvm_printer;
//	printer_type out_format;
//
//	function new (printer_type x=YAML_PRINTER);
//		super.new();
//		out_format = x;
//	endfunction
//
//	virtual function string emit();
//		if(out_format==YAML_PRINTER) return emit_YAML();
//		else return "Error: printer format not find ...\n";
//		m_rows.delete();
//		//string rtn_s,indent;
//		//foreach(m_rows[i]) begin
//		//	indent = indent_blank(m_rows[i].level);
//		//	rtn_s = {rtn_s,$psprintf("%0s,level=%0d,name=%0s,type_name=%0s,size=%0d,value=%p\n",
//		//		indent,m_rows[i].level,m_rows[i].name,m_rows[i].type_name,m_rows[i].size,m_rows[i].val)};
//		//end
//	endfunction
//	function string indent_blank(int num);
//		string rtn_str="";
//		for(int i=0;i<num;i++) rtn_str={rtn_str,"----"};
//		//for(int i=0;i<num;i++) rtn_str={rtn_str,knobs.indent};
//		return rtn_str;
//	endfunction
//	function string emit_YAML();
//		string rtn_s,indent,obj_name;
//		int pre_level;
//		foreach(m_rows[i]) begin
//			indent = indent_blank(m_rows[i].level);
//			if(i>0) pre_level=m_rows[i-1].level;
//			rtn_s = {rtn_s,$psprintf("%0s,level=%0d,name=%0s,type_name=%0s,size=%p,value=%p\n",
//				indent,m_rows[i].level,m_rows[i].name,m_rows[i].type_name,m_rows[i].size,m_rows[i].val)};
//			//if(m_rows[i].level+1==pre_level) begin
//			//	obj_name=m_rows[i-1].name;
//			//	rtn_s = {rtn_s,$psprintf("%0s%0s:\n",indent,m_rows[i].name)};
//			//end else begin
//			//	obj_name="";
//			//	rtn_s = {rtn_s,$psprintf("%0s%0s%0s:%p\n",indent,obj_name,m_rows[i].name,m_rows[i].val)};
//			//end
//		end
//		return rtn_s;
//	endfunction
//endclass
