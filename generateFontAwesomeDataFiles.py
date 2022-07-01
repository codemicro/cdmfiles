#!/usr/bin/env python3
# Convert FontAwesome6 fonts into Nim constants. This is NOT for general use.
#
# This script is an altered version of the below project by Juliette Foucaut
# and Doug Binks, which is licensed under the Zlib license.
# https://github.com/juliettef/IconFontCppHeaders/


import requests
import yaml
import os
import sys

if sys.version_info[0] < 3:
    raise Exception("Python 3 or a more recent version is required.")

# Fonts


class Font:
    font_name = "[ ERROR - missing font name ]"
    font_abbr = "[ ERROR - missing font abbreviation ]"
    font_minmax_abbr = ""  # optional - use if min and max defines must be differentiated. See Font Awesome Brand for example.
    font_data = "[ ERROR - missing font data file or url ]"
    ttfs = "[ ERROR - missing ttf ]"

    @classmethod
    def get_icons(cls, input_data):
        # intermediate representation of the fonts data, identify the min and max
        print(
            "[ ERROR - missing implementation of class method get_icons for {!s} ]".format(
                cls.font_name
            )
        )
        icons_data = {}
        icons_data.update(
            {
                "font_min": "[ ERROR - missing font min ]",
                "font_max": "[ ERROR - missing font max ]",
                "icons": "[ ERROR - missing list of pairs [ font icon name, code ]]",
            }
        )
        return icons_data

    @classmethod
    def get_intermediate_representation(cls):
        font_ir = {}
        if "http" in cls.font_data:  # if url, download data
            response = requests.get(cls.font_data, timeout=2)
            if response.status_code == 200:
                input_raw = response.text
                print("Downloaded - " + cls.font_name)
            else:
                raise Exception("Download failed - " + cls.font_name)
        else:  # read data from file if present
            if os.path.isfile(cls.font_data):
                with open(cls.font_data, "r") as f:
                    input_raw = f.read()
                    f.close()
                    print("File read - " + cls.font_name)
            else:
                raise Exception("File " + cls.font_name + " missing - " + cls.font_data)
        if input_raw:
            icons_data = cls.get_icons(input_raw)
            font_ir.update(icons_data)
            font_ir.update(
                {
                    "font_data": cls.font_data,
                    "font_name": cls.font_name,
                    "font_abbr": cls.font_abbr,
                    "font_minmax_abbr": cls.font_minmax_abbr,
                    "ttfs": cls.ttfs,
                }
            )
            print("Generated intermediate data - " + cls.font_name)
        return font_ir


class FontFA6(Font):  # Font Awesome version 6 - Regular and Solid styles
    font_name = "Font Awesome 6"
    font_abbr = "FA"
    font_data = "https://github.com/FortAwesome/Font-Awesome/raw/6.x/metadata/icons.yml"
    ttfs = [
        [
            "FAS",
            "fa-solid-900.ttf",
            "https://github.com/FortAwesome/Font-Awesome/blob/6.x/webfonts/fa-solid-900.ttf",
        ]
    ]
    font_fa_style = ["solid"]

    @classmethod
    def get_icons(cls, input_data):
        icons_data = {}
        data = yaml.safe_load(input_data)
        if data:
            font_min = "0x10ffff"
            font_min_int = int(font_min, 16)
            font_max_16 = "0x0"  # 16 bit max
            font_max_16_int = int(font_max_16, 16)
            font_max = "0x0"
            font_max_int = int(font_max, 16)
            icons = []
            for key in data:
                item = data[key]
                for style in item["styles"]:
                    if style in cls.font_fa_style:
                        item_unicode = item["unicode"].zfill(4)
                        if [key, item_unicode] not in icons:
                            item_int = int(item_unicode, 16)
                            if (
                                item_int < font_min_int and item_int > 0x0127
                            ):  # exclude ASCII characters code points
                                font_min = item_unicode
                                font_min_int = item_int
                            if (
                                item_int > font_max_16_int and item_int <= 0xFFFF
                            ):  # exclude code points > 16 bits
                                font_max_16 = item_unicode
                                font_max_16_int = item_int
                            if item_int > font_max_int:
                                font_max = item_unicode
                                font_max_int = item_int
                            icons.append([key, item_unicode])
            icons_data.update(
                {
                    "font_min": font_min,
                    "font_max_16": font_max_16,
                    "font_max": font_max,
                    "icons": icons,
                }
            )
        return icons_data


# Languages


class Language:
    language_name = "[ ERROR - missing language name ]"
    file_name = "[ ERROR - missing file name ]"
    intermediate = {}

    def __init__(self, intermediate):
        self.intermediate = intermediate

    @classmethod
    def prelude(cls):
        print(
            "[ ERROR - missing implementation of class method prelude for {!s} ]".format(
                cls.language_name
            )
        )
        result = "[ ERROR - missing prelude ]"
        return result

    @classmethod
    def lines_minmax(cls):
        print(
            "[ ERROR - missing implementation of class method lines_minmax for {!s} ]".format(
                cls.language_name
            )
        )
        result = "[ ERROR - missing min and max ]"
        return result

    @classmethod
    def line_icon(cls, icon):
        print(
            "[ ERROR - missing implementation of class method line_icon for {!s} ]".format(
                cls.language_name
            )
        )
        result = "[ ERROR - missing icon line ]"
        return result

    @classmethod
    def epilogue(cls):
        return ""

    @classmethod
    def convert(cls):
        result = cls.prelude() + cls.lines_minmax()
        for icon in cls.intermediate.get("icons"):
            line_icon = cls.line_icon(icon)
            result += line_icon
        result += cls.epilogue()
        print(
            "Converted - {!s} for {!s}".format(
                cls.intermediate.get("font_name"), cls.language_name
            )
        )
        return result

    @classmethod
    def save_to_file(cls):
        filename = cls.file_name.format(
            name=str(cls.intermediate.get("font_name")).replace(" ", "")
        )
        converted = cls.convert()
        with open(filename, "w") as f:
            f.write(converted)
            f.close()
        print("Saved - {!s}".format(filename))


class LanguageNim(Language):
    language_name = "Nim"
    file_name = "src/fontawesome.nim"

    @classmethod
    def prelude(cls):
        tmpl_prelude = """# THIS FILE IS GENERATED. DO NOT EDIT.
#
# Generated by generateFontAwesomeData.py

"""
        ttf_files = []
        for ttf in cls.intermediate.get("ttfs"):
            ttf_files.append(ttf[2])
        result = tmpl_prelude.format(
            lang=cls.language_name,
            font_data=cls.intermediate.get("font_data"),
            ttf_files=", ".join(ttf_files),
        )
        return result + """var
    faData* {.header: "fontAwesomeContent.cpp", importc: "FontAwesome_compressed_data"}: pointer
    faDataSize* {.header: "fontAwesomeContent.cpp", importc: "FontAwesome_compressed_size"}: int32
    
const
"""

    @classmethod
    def lines_minmax(cls):
        tmpl_line_minmax = "    Icon{minmax}{abbr}* = 0x{val}\n"
        abbreviation = (
            cls.intermediate.get("font_minmax_abbr")
            if cls.intermediate.get("font_minmax_abbr")
            else cls.intermediate.get("font_abbr")
        )
        result = (
            tmpl_line_minmax.format(
                minmax="Min",
                abbr=cls.to_camelcase(abbreviation),
                val=cls.intermediate.get("font_min"),
            )
            + tmpl_line_minmax.format(
                minmax="Max16",
                abbr=cls.to_camelcase(abbreviation),
                val=cls.intermediate.get("font_max_16"),
            )
            + tmpl_line_minmax.format(
                minmax="Max",
                abbr=cls.to_camelcase(abbreviation),
                val=cls.intermediate.get("font_max"),
            )
        )
        return result.replace("Fa", "FA")

    @classmethod
    def line_icon(cls, icon):
        tmpl_line_icon = '    Icon{abbr}{icon}* = "{code}"\n'
        icon_name = str.upper(icon[0]).replace("-", "_")
        icon_code = repr(chr(int(icon[1], 16)).encode("utf-8"))[2:-1]
        result = tmpl_line_icon.format(
            abbr=cls.intermediate.get("font_abbr"),
            icon=cls.to_camelcase(icon_name),
            code=icon_code,
        )
        return result

    @classmethod
    def to_camelcase(cls, text):
        parts = text.split("_")
        for i in range(len(parts)):
            p = parts[i]
            parts[i] = p[0].upper() + p[1:].lower()
        return "".join(parts)

# Main
fonts = [FontFA6]
languages = [LanguageNim]

intermediates = []
for font in fonts:
    try:
        font_intermediate = font.get_intermediate_representation()
        if font_intermediate:
            intermediates.append(font_intermediate)
    except Exception as e:
        print("[ ERROR: {!s} ]".format(e))
if intermediates:
    for interm in intermediates:
        Language.intermediate = interm
        for lang in languages:
            if lang:
                lang.save_to_file()
