import idaapi
import idautils
import idc

# 获得所有已知API的集合
def get_known_apis():
    known_apis = set()
    def imp_cb(ea, name, ord):
        if name:
            known_apis.add(name)
        return True
    for i in range(ida_nalt.get_import_module_qty()):
        ida_nalt.enum_import_names(i, imp_cb)
    return known_apis

known_apis = get_known_apis()

def get_called_functions(start_ea, end_ea, known_apis):
    called_functions = set()
    for head in idautils.Heads(start_ea, end_ea):
        if idc.is_code(idc.get_full_flags(head)):
            insn = idautils.DecodeInstruction(head)
            if insn:
                # 检查是否为 call 指令或间接调用
                if insn.get_canon_mnem() == "call" or (insn.Op1.type == idaapi.o_reg and insn.Op2.type == idaapi.o_phrase):
                    func_addr = insn.Op1.addr if insn.Op1.type != idaapi.o_void else insn.Op2.addr
                    if func_addr != idaapi.BADADDR:
                        func_name = idc.get_name(func_addr, ida_name.GN_VISIBLE)
                        if not func_name:  # 对于未命名的函数，使用地址
                            func_name = "sub_{:X}".format(func_addr)
                        called_functions.add(func_name)
    return called_functions

def main(name, known_apis):
    main_addr = idc.get_name_ea_simple(name)
    if main_addr == idaapi.BADADDR:
        print("找不到 '{}' 函数。".format(name))
        return
    main_end_addr = idc.find_func_end(main_addr)
    main_called_functions = get_called_functions(main_addr, main_end_addr, known_apis)
    print("被 '{}' 调用的函数:".format(name))
    for func_name in main_called_functions:
        print(func_name)
        if func_name in known_apis:
            continue
        func_ea = idc.get_name_ea_simple(func_name)
        if func_ea == idaapi.BADADDR:
            continue
        if 'sub' not in func_name:
            continue
        func_end_addr = idc.find_func_end(func_ea)
        called_by_func = get_called_functions(func_ea, func_end_addr, known_apis)
        print("\t被 {} 调用的函数/APIs: ".format(func_name))
        for sub_func_name in called_by_func:
            print("\t\t{}".format(sub_func_name))

if __name__ == "__main__":
    names = ['_main', '_WinMain@16', '_DllMain@12']
    for name in names:
        main(name, known_apis)