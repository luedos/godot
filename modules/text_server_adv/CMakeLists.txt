add_env(text-server-adv-env
	COMPONENTS
		modules-env
)

add_lib(text-server-adv-lib
	OBJECT
	PARENT_LIB
		modules-lib
	COMPONENTS
		text-server-adv-env
		global-warnings-env
)

if ("svg" IN_LIST MODULES_LIST)
	target_include_directories(text-server-adv-env INTERFACE
		"${ENGINE_SOURCE_DIR}/thirdparty/thorvg/inc"
		"${ENGINE_SOURCE_DIR}/thirdparty/thorvg/src/lib"
	)
endif()

inline_if(__FREETYPE_ENABLED "freetype" IN_LIST MODULES_LIST)
inline_if(__MSDFGEN_ENABLED "msdfgen" IN_LIST MODULES_LIST)

if (godot_builtin_harfbuzz)
	add_lib(thirdparty-harfbuzz-lib
		PARENT_ENV
			global-libs-list
		COMPONENTS
			text-server-adv-env
			thirdparty-warnings-env
	)

	set(__THIRDPARTY_HARFBUZZ_SOURCES
		"src/hb-aat-layout.cc"
		"src/hb-aat-map.cc"
		"src/hb-blob.cc"
		"src/hb-buffer-serialize.cc"
		"src/hb-buffer-verify.cc"
		"src/hb-buffer.cc"
		# "src/hb-cairo-utils.cc"
		# "src/hb-cairo.cc"
		"src/hb-common.cc"
		# "src/hb-coretext.cc"
		# "src/hb-directwrite.cc"
		"src/hb-draw.cc"
		"src/hb-face-builder.cc"
		"src/hb-face.cc"
		"src/hb-fallback-shape.cc"
		"src/hb-font.cc"
		# "src/hb-gdi.cc"
		# "src/hb-glib.cc"
		# "src/hb-gobject-structs.cc"
		"src/hb-icu.cc"
		"src/hb-map.cc"
		"src/hb-number.cc"
		"src/hb-ot-cff1-table.cc"
		"src/hb-ot-cff2-table.cc"
		"src/hb-ot-color.cc"
		"src/hb-ot-face.cc"
		"src/hb-ot-font.cc"
		"src/hb-ot-layout.cc"
		"src/hb-ot-map.cc"
		"src/hb-ot-math.cc"
		"src/hb-ot-meta.cc"
		"src/hb-ot-metrics.cc"
		"src/hb-ot-name.cc"
		"src/hb-ot-shaper-arabic.cc"
		"src/hb-ot-shaper-default.cc"
		"src/hb-ot-shaper-hangul.cc"
		"src/hb-ot-shaper-hebrew.cc"
		"src/hb-ot-shaper-indic-table.cc"
		"src/hb-ot-shaper-indic.cc"
		"src/hb-ot-shaper-khmer.cc"
		"src/hb-ot-shaper-myanmar.cc"
		"src/hb-ot-shaper-syllabic.cc"
		"src/hb-ot-shaper-thai.cc"
		"src/hb-ot-shaper-use.cc"
		"src/hb-ot-shaper-vowel-constraints.cc"
		"src/hb-ot-shape-fallback.cc"
		"src/hb-ot-shape-normalize.cc"
		"src/hb-ot-shape.cc"
		"src/hb-ot-tag.cc"
		"src/hb-ot-var.cc"
		"src/hb-outline.cc"
		"src/hb-paint-extents.cc"
		"src/hb-paint.cc"
		"src/hb-set.cc"
		"src/hb-shape-plan.cc"
		"src/hb-shape.cc"
		"src/hb-shaper.cc"
		"src/hb-static.cc"
		"src/hb-style.cc"
		"src/hb-subset-cff-common.cc"
		"src/hb-subset-cff1.cc"
		"src/hb-subset-cff2.cc"
		"src/hb-subset-input.cc"
		"src/hb-subset-instancer-solver.cc"
		"src/hb-subset-plan.cc"
		"src/hb-subset-repacker.cc"
		"src/hb-subset.cc"
		"src/hb-ucd.cc"
		"src/hb-unicode.cc"
		# "src/hb-uniscribe.cc"
	)

	if (__FREETYPE_ENABLED)
		list(APPEND __THIRDPARTY_HARFBUZZ_SOURCES "src/hb-ft.cc")
		if (godot_graphite)
			list(APPEND __THIRDPARTY_HARFBUZZ_SOURCES "src/hb-graphite2.cc")
		endif()
	endif()

	set(__THIRDPARTY_HARFBUZZ_PATH "${ENGINE_SOURCE_DIR}/thirdparty/harfbuzz")
	target_sources_from_path(thirdparty-harfbuzz-lib PRIVATE "${__THIRDPARTY_HARFBUZZ_PATH}"
		${__THIRDPARTY_HARFBUZZ_SOURCES}
	)

	target_include_directories(text-server-adv-env INTERFACE "${__THIRDPARTY_HARFBUZZ_PATH}/src")
	target_compile_definitions(thirdparty-harfbuzz-lib PRIVATE "HAVE_ICU")
	
	if (godot_builtin_icu4c)
		target_include_directories(thirdparty-harfbuzz-lib PRIVATE
			"${ENGINE_SOURCE_DIR}/thirdparty/icu4c/common"
			"${ENGINE_SOURCE_DIR}/thirdparty/icu4c/i18n"
		)
		target_compile_definitions(thirdparty-harfbuzz-lib PRIVATE
			"U_HAVE_LIB_SUFFIX=1"
			"U_LIB_SUFFIX_C_NAME=_godot"
			"HAVE_ICU_BUILTIN"
		)
	endif()

	if (__FREETYPE_ENABLED)
		target_compile_definitions(thirdparty-harfbuzz-lib PRIVATE "HAVE_FREETYPE")

		if (godot_graphite)
			target_compile_definitions(thirdparty-harfbuzz-lib PRIVATE "HAVE_GRAPHITE2")
		endif()

		if (godot_builtin_freetype)
			target_include_directories(thirdparty-harfbuzz-lib PRIVATE "${ENGINE_SOURCE_DIR}/thirdparty/freetype/include")
		endif()

		if (godot_builtin_graphite AND godot_graphite)
			target_include_directories(thirdparty-harfbuzz-lib PRIVATE "${ENGINE_SOURCE_DIR}/thirdparty/graphite/include")
			target_compile_definitions(thirdparty-harfbuzz-lib PRIVATE "GRAPHITE2_STATIC")
		endif()
	endif()

	if (godot_platform MATCHES "(android|linuxbsd|web)")
		target_compile_definitions(thirdparty-harfbuzz-lib PRIVATE "HAVE_PTHREAD")
	endif()

	# Needs to be appended to arrive after libscene in the linker call.
	add_link_dependencies(scene-lib thirdparty-harfbuzz-lib)
	add_link_dependencies(modules-lib thirdparty-harfbuzz-lib)
endif()

if (godot_builtin_graphite AND __FREETYPE_ENABLED AND godot_graphite)
	add_lib(thirdparty-graphite-lib
		PARENT_ENV
			global-libs-list
		COMPONENTS
			text-server-adv-env
			thirdparty-warnings-env
	)

	set(__THIRDPARTY_GRAPHITE_SOURCES
		"src/gr_char_info.cpp"
		"src/gr_face.cpp"
		"src/gr_features.cpp"
		"src/gr_font.cpp"
		"src/gr_logging.cpp"
		"src/gr_segment.cpp"
		"src/gr_slot.cpp"
		"src/CmapCache.cpp"
		"src/Code.cpp"
		"src/Collider.cpp"
		"src/Decompressor.cpp"
		"src/Face.cpp"
		# "src/FileFace.cpp"
		"src/FeatureMap.cpp"
		"src/Font.cpp"
		"src/GlyphCache.cpp"
		"src/GlyphFace.cpp"
		"src/Intervals.cpp"
		"src/Justifier.cpp"
		"src/NameTable.cpp"
		"src/Pass.cpp"
		"src/Position.cpp"
		"src/Segment.cpp"
		"src/Silf.cpp"
		"src/Slot.cpp"
		"src/Sparse.cpp"
		"src/TtfUtil.cpp"
		"src/UtfCodec.cpp"
		"src/FileFace.cpp"
		"src/json.cpp"
	)

	if (NOT MSVC)
		list(APPEND __THIRDPARTY_GRAPHITE_SOURCES "src/direct_machine.cpp")
	else()
		list(APPEND __THIRDPARTY_GRAPHITE_SOURCES "src/call_machine.cpp")
	endif()

	set(__THIRDPARTY_GRAPHITE_PATH "${ENGINE_SOURCE_DIR}/thirdparty/graphite")

	target_sources_from_path(thirdparty-graphite-lib PRIVATE "${__THIRDPARTY_GRAPHITE_PATH}"
		${__THIRDPARTY_GRAPHITE_SOURCES}
	)

	target_include_directories(thirdparty-graphite-lib PRIVATE
		"${__THIRDPARTY_GRAPHITE_PATH}/src"
		"${__THIRDPARTY_GRAPHITE_PATH}/include"
	)
	target_compile_definitions(thirdparty-graphite-lib PRIVATE
		"GRAPHITE2_STATIC"
		"GRAPHITE2_NTRACING"
		"GRAPHITE2_NFILEFACE"
	)

	add_link_dependencies(scene-lib thirdparty-graphite-lib)
	add_link_dependencies(modules-lib thirdparty-graphite-lib)
endif()

if (godot_builtin_icu4c)
	add_lib(thirdparty-icu-lib
		PARENT_ENV
			global-libs-list
		COMPONENTS
			text-server-adv-env
			thirdparty-warnings-env
	)

	set(__THIRDPARTY_ICU_PATH "${ENGINE_SOURCE_DIR}/thirdparty/icu4c")
	target_sources_from_path(thirdparty-icu-lib PRIVATE "${__THIRDPARTY_ICU_PATH}"
		"common/appendable.cpp"
		"common/bmpset.cpp"
		"common/brkeng.cpp"
		"common/brkiter.cpp"
		"common/bytesinkutil.cpp"
		"common/bytestream.cpp"
		"common/bytestrie.cpp"
		"common/bytestriebuilder.cpp"
		"common/bytestrieiterator.cpp"
		"common/caniter.cpp"
		"common/characterproperties.cpp"
		"common/chariter.cpp"
		"common/charstr.cpp"
		"common/cmemory.cpp"
		"common/cstr.cpp"
		"common/cstring.cpp"
		"common/cwchar.cpp"
		"common/dictbe.cpp"
		"common/dictionarydata.cpp"
		"common/dtintrv.cpp"
		"common/edits.cpp"
		"common/emojiprops.cpp"
		"common/errorcode.cpp"
		"common/filteredbrk.cpp"
		"common/filterednormalizer2.cpp"
		"common/icudataver.cpp"
		"common/icuplug.cpp"
		"common/loadednormalizer2impl.cpp"
		"common/localebuilder.cpp"
		"common/localematcher.cpp"
		"common/localeprioritylist.cpp"
		"common/locavailable.cpp"
		"common/locbased.cpp"
		"common/locdispnames.cpp"
		"common/locdistance.cpp"
		"common/locdspnm.cpp"
		"common/locid.cpp"
		"common/loclikely.cpp"
		"common/loclikelysubtags.cpp"
		"common/locmap.cpp"
		"common/locresdata.cpp"
		"common/locutil.cpp"
		"common/lsr.cpp"
		"common/lstmbe.cpp"
		"common/messagepattern.cpp"
		"common/mlbe.cpp"
		"common/normalizer2.cpp"
		"common/normalizer2impl.cpp"
		"common/normlzr.cpp"
		"common/parsepos.cpp"
		"common/patternprops.cpp"
		"common/pluralmap.cpp"
		"common/propname.cpp"
		"common/propsvec.cpp"
		"common/punycode.cpp"
		"common/putil.cpp"
		"common/rbbi.cpp"
		"common/rbbi_cache.cpp"
		"common/rbbidata.cpp"
		"common/rbbinode.cpp"
		"common/rbbirb.cpp"
		"common/rbbiscan.cpp"
		"common/rbbisetb.cpp"
		"common/rbbistbl.cpp"
		"common/rbbitblb.cpp"
		"common/resbund.cpp"
		"common/resbund_cnv.cpp"
		"common/resource.cpp"
		"common/restrace.cpp"
		"common/ruleiter.cpp"
		"common/schriter.cpp"
		"common/serv.cpp"
		"common/servlk.cpp"
		"common/servlkf.cpp"
		"common/servls.cpp"
		"common/servnotf.cpp"
		"common/servrbf.cpp"
		"common/servslkf.cpp"
		"common/sharedobject.cpp"
		"common/simpleformatter.cpp"
		"common/static_unicode_sets.cpp"
		"common/stringpiece.cpp"
		"common/stringtriebuilder.cpp"
		"common/uarrsort.cpp"
		"common/ubidi.cpp"
		"common/ubidi_props.cpp"
		"common/ubidiln.cpp"
		"common/ubiditransform.cpp"
		"common/ubidiwrt.cpp"
		"common/ubrk.cpp"
		"common/ucase.cpp"
		"common/ucasemap.cpp"
		"common/ucasemap_titlecase_brkiter.cpp"
		"common/ucat.cpp"
		"common/uchar.cpp"
		"common/ucharstrie.cpp"
		"common/ucharstriebuilder.cpp"
		"common/ucharstrieiterator.cpp"
		"common/uchriter.cpp"
		"common/ucln_cmn.cpp"
		"common/ucmndata.cpp"
		"common/ucnv.cpp"
		"common/ucnv2022.cpp"
		"common/ucnv_bld.cpp"
		"common/ucnv_cb.cpp"
		"common/ucnv_cnv.cpp"
		"common/ucnv_ct.cpp"
		"common/ucnv_err.cpp"
		"common/ucnv_ext.cpp"
		"common/ucnv_io.cpp"
		"common/ucnv_lmb.cpp"
		"common/ucnv_set.cpp"
		"common/ucnv_u16.cpp"
		"common/ucnv_u32.cpp"
		"common/ucnv_u7.cpp"
		"common/ucnv_u8.cpp"
		"common/ucnvbocu.cpp"
		"common/ucnvdisp.cpp"
		"common/ucnvhz.cpp"
		"common/ucnvisci.cpp"
		"common/ucnvlat1.cpp"
		"common/ucnvmbcs.cpp"
		"common/ucnvscsu.cpp"
		"common/ucnvsel.cpp"
		"common/ucol_swp.cpp"
		"common/ucptrie.cpp"
		"common/ucurr.cpp"
		"common/udata.cpp"
		"common/udatamem.cpp"
		"common/udataswp.cpp"
		"common/uenum.cpp"
		"common/uhash.cpp"
		"common/uhash_us.cpp"
		"common/uidna.cpp"
		"common/uinit.cpp"
		"common/uinvchar.cpp"
		"common/uiter.cpp"
		"common/ulist.cpp"
		"common/uloc.cpp"
		"common/uloc_keytype.cpp"
		"common/uloc_tag.cpp"
		"common/umapfile.cpp"
		"common/umath.cpp"
		"common/umutablecptrie.cpp"
		"common/umutex.cpp"
		"common/unames.cpp"
		"common/unifiedcache.cpp"
		"common/unifilt.cpp"
		"common/unifunct.cpp"
		"common/uniset.cpp"
		"common/uniset_closure.cpp"
		"common/uniset_props.cpp"
		"common/unisetspan.cpp"
		"common/unistr.cpp"
		"common/unistr_case.cpp"
		"common/unistr_case_locale.cpp"
		"common/unistr_cnv.cpp"
		"common/unistr_props.cpp"
		"common/unistr_titlecase_brkiter.cpp"
		"common/unorm.cpp"
		"common/unormcmp.cpp"
		"common/uobject.cpp"
		"common/uprops.cpp"
		"common/ures_cnv.cpp"
		"common/uresbund.cpp"
		"common/uresdata.cpp"
		"common/usc_impl.cpp"
		"common/uscript.cpp"
		"common/uscript_props.cpp"
		"common/uset.cpp"
		"common/uset_props.cpp"
		"common/usetiter.cpp"
		# "common/ushape.cpp"
		"common/usprep.cpp"
		"common/ustack.cpp"
		"common/ustr_cnv.cpp"
		"common/ustr_titlecase_brkiter.cpp"
		"common/ustr_wcs.cpp"
		"common/ustrcase.cpp"
		"common/ustrcase_locale.cpp"
		"common/ustrenum.cpp"
		"common/ustrfmt.cpp"
		"common/ustring.cpp"
		"common/ustrtrns.cpp"
		"common/utext.cpp"
		"common/utf_impl.cpp"
		"common/util.cpp"
		"common/util_props.cpp"
		"common/utrace.cpp"
		"common/utrie.cpp"
		"common/utrie2.cpp"
		"common/utrie2_builder.cpp"
		"common/utrie_swap.cpp"
		"common/uts46.cpp"
		"common/utypes.cpp"
		"common/uvector.cpp"
		"common/uvectr32.cpp"
		"common/uvectr64.cpp"
		"common/wintz.cpp"
		"i18n/scriptset.cpp"
		"i18n/ucln_in.cpp"
		"i18n/uspoof.cpp"
		"i18n/uspoof_impl.cpp"
	)

	set(__ICU_DATA_NAME "icudt73l.dat")

	if (godot_editor_build)
		add_python_generator_command(cmake_icu_data_gen cmake_make_icu_data
			TARGET_FILES "${__THIRDPARTY_ICU_PATH}/icudata.gen.h"
			SOURCE_FILES "${__THIRDPARTY_ICU_PATH}/${__ICU_DATA_NAME}"
			CREATE_CUSTOM_TARGET icu-data-header-gen
		)
		add_dependencies(text-server-adv-lib icu-data-header-gen)
		target_include_directories(text-server-adv-env INTERFACE "${__THIRDPARTY_ICU_PATH}")
	else()
		target_sources(thirdparty-icu-lib PRIVATE "icu_data/icudata_stub.cpp")
	endif()

	target_include_directories(text-server-adv-env INTERFACE
		"${__THIRDPARTY_ICU_PATH}/common"
		"${__THIRDPARTY_ICU_PATH}/i18n"
	)
	
	target_compile_definitions(thirdparty-icu-lib PRIVATE
		"U_STATIC_IMPLEMENTATION"
		"U_COMMON_IMPLEMENTATION"
		"UCONFIG_NO_COLLATION"
		"UCONFIG_NO_CONVERSION"
		"UCONFIG_NO_FORMATTING"
		"UCONFIG_NO_SERVICE"
		"UCONFIG_NO_IDNA"
		"UCONFIG_NO_FILE_IO"
		"UCONFIG_NO_TRANSLITERATION"
		"UCONFIG_NO_REGULAR_EXPRESSIONS"
		"PKGDATA_MODE=static"
		"U_ENABLE_DYLOAD=0"
	)
	
	target_compile_definitions(text-server-adv-env INTERFACE
		"U_HAVE_LIB_SUFFIX=1"
		"U_LIB_SUFFIX_C_NAME=_godot"
		"ICU_DATA_NAME=${__ICU_DATA_NAME}"
	)

	if (godot_editor_build)
		target_compile_definitions(text-server-adv-env INTERFACE "ICU_STATIC_DATA")
	endif()

	add_link_dependencies(scene-lib thirdparty-icu-lib)
	add_link_dependencies(modules-lib thirdparty-icu-lib)
endif()

if (godot_builtin_msdfgen AND "msdfgen" IN_LIST MODULES_LIST)
	# Treat msdfgen headers as system headers to avoid raising warnings.
	target_include_directories(text-server-adv-lib SYSTEM PRIVATE "${ENGINE_SOURCE_DIR}/thirdparty/msdfgen")
endif()

if (godot_builtin_freetype AND __FREETYPE_ENABLED)
	target_compile_definitions(text-server-adv-lib PRIVATE "FT_CONFIG_OPTION_USE_BROTLI")
	target_include_directories(text-server-adv-lib PRIVATE "${ENGINE_SOURCE_DIR}/freetype/include")
endif()

if (godot_builtin_graphite AND __FREETYPE_ENABLED AND godot_graphite)
	target_include_directories(text-server-adv-lib PRIVATE "${ENGINE_SOURCE_DIR}/graphite/include")
endif()

target_glob_sources(text-server-adv-lib PRIVATE "*.cpp")