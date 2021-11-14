def generate_encryption_key_header(env_key=""):
	txt = "0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0"
	if env_key != "":
	    txt = ""
	    ec_valid = True
	    if len(env_key) != 64:
	        ec_valid = False
	    else:
	
	        for i in range(len(env_key) >> 1):
	            if i > 0:
	                txt += ","
	            txts = "0x" + env_key[i * 2 : i * 2 + 2]
	            try:
	                int(txts, 16)
	            except:
	                ec_valid = False
	            txt += txts
	    if not ec_valid:
	        txt = "0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0"
	        print("Invalid AES256 encryption key, not 64 bits hex: " + env_key)
	
	# NOTE: It is safe to generate this file here, since this is still executed serially
	with open("script_encryption_key.gen.cpp", "w") as f:
	    f.write('#include "core/project_settings.h"\nuint8_t script_encryption_key[32]={' + txt + "};\n")