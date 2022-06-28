import uvm_pkg::*;
`include "uvm_macros.svh"
class uvm_yaml_printer extends uvm_printer;
	function new ();
		super.new();
	endfunction

	virtual function string emit();
		string rtn_s,indent;
		int cur_level,next_level;
		bit array_flag;
		foreach(m_rows[i]) begin
			array_flag=0;
			indent = {m_rows[i].level{"    "}};

			if(i+1<m_rows.size()) next_level=m_rows[i+1].level;
			cur_level = m_rows[i].level;

			if(m_rows[i].name.substr(0,0)=="[") begin
				indent={indent,"- "};
				array_flag=1;
			end

			if(cur_level+1==next_level) begin
				if(array_flag) 
				rtn_s = {rtn_s,$psprintf("%0s\n",indent)};
				else
				rtn_s = {rtn_s,$psprintf("%0s%0s: \n",indent,m_rows[i].name)};
			end else begin
				if(array_flag) begin
					rtn_s = {rtn_s,$psprintf("%0s%p\n",indent,m_rows[i].val)};
				end else begin
					rtn_s = {rtn_s,$psprintf("%0s%0s: %p\n",indent,m_rows[i].name,m_rows[i].val)};
				end
			end
		end
		m_rows.delete();
		return rtn_s;
	endfunction
endclass
class uvm_json_printer extends uvm_printer;
	function new ();
		super.new();
	endfunction
	virtual function string emit();
		string rtn_s,indent,suffix,text;
		string nextType,objType[$];
		int cur_level,next_level;
		bit array_flag;
		rtn_s="{\n";
		objType.delete();
		foreach(m_rows[i]) begin
			array_flag=0;
			indent = {m_rows[i].level{"    "}};
			suffix = "";

			if(i+1<m_rows.size()) next_level=m_rows[i+1].level;
			cur_level = m_rows[i].level;

			if(m_rows[i].name.substr(0,0)=="[") array_flag=1;

			if(cur_level+1==next_level) 
				if(array_flag)	text="";
				else	        text=$psprintf("\"%0s\":",m_rows[i].name);
			else begin
				if(array_flag) text=$psprintf("%p",m_rows[i].val);
				else		   text=$psprintf("\"%0s\": %p",m_rows[i].name,m_rows[i].val);
			end	

			if(cur_level+1==next_level) begin
				if(m_rows[i+1].name.substr(0,0)!="[") nextType="object";
				else nextType="array";
				if(objType.size()) begin
					case({objType[$],"-",nextType})
						"object-array" : begin indent={indent,"" };suffix="[";end
						"array-array"  : begin indent={indent,""};suffix="[";end//
						"object-object": begin indent={indent,"" };suffix="{";end
						"array-object" : begin indent={indent,""};suffix="{";end//
					endcase
				end else begin indent={indent,""};suffix="{";end
				rtn_s={rtn_s,indent,text,suffix,"\n"};
				objType.push_back(nextType);
				continue;
			end
			else if(cur_level==next_level+1) begin
				if(m_rows[i+1].name.substr(0,0)!="[") nextType="object";
				else nextType="array";
				case({objType[$],"-",nextType})
					"object-array" : begin indent={indent,"" };suffix="},";end
					"array-array"  : begin indent={indent,""};suffix="],";end//
					"object-object": begin indent={indent,"" };suffix="},";end
					"array-object" : begin indent={indent,""};suffix="],";end//
				endcase
				objType.pop_back();
				//objType.push_back(nextType);
			end else if(i+1==m_rows.size()) begin
				objType.reverse();
				foreach(objType[i]) begin
					if (objType[i]=="object") suffix={suffix,"}"};
					if (objType[i]=="array")  suffix={suffix,"]"};
				end
			end	else begin
				if (objType[$]=="array")  begin
					indent={indent,""};//
					suffix=",";
				end	else begin
					indent={indent,""};
					suffix=",";
				end
			end
			rtn_s={rtn_s,indent,text,suffix,"\n"};
		end
		rtn_s={rtn_s,"}\n"};
		m_rows.delete();
		return rtn_s;
	endfunction
endclass
class uvm_xml_printer extends uvm_printer;
	function new ();
		super.new();
	endfunction
	virtual function string emit();
		return "uvm_hybrid_printer: xml format to do, may be next release...\n";
	endfunction
endclass

virtual class uvm_hybrid_printer ;
typedef enum {
		JSON_PRINTER,
		YAML_PRINTER,
		XML_PRINTER,
		TABLE_PRINTER,
		TREE_PRINTER
} printer_type;
	static function uvm_printer create_printer(printer_type x_type=TABLE_PRINTER);
		case (x_type)
			TABLE_PRINTER: begin uvm_table_printer printer=new();return printer;end
			TREE_PRINTER : begin uvm_tree_printer  printer=new();return printer;end
			YAML_PRINTER : begin uvm_yaml_printer  printer=new();return printer;end
			JSON_PRINTER : begin uvm_json_printer  printer=new();return printer;end
			XML_PRINTER  : begin uvm_xml_printer   printer=new();return printer;end
			default	     : begin uvm_table_printer printer=new();return printer;end
		endcase
	endfunction
endclass
///////////////////////////////////////////
