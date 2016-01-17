#!/bin/ruby

# 13/01/2016
# Joachim Deelen jdeelen@micabo.de
# Transforms a .tsv into an XCode .strings file
# Download TSV-File from GoogleDocs to read strings for different locales from table-columns
# Based on the idea from Constantine Karlis. dino@constantinekarlis.com
# © 2016 micabo-software UG

# This file must be executed as a Xcode Run-Script Build-Phase because
# it uses some environment variables that are set by Xcode

require 'open-uri'
require 'fileutils'

# Holds the Key/Value pairs for a certain locale.
# These are extracted from a GoogleDocs Spreadsheet
# and written to the Localizeable.strings file
class StringsContainer
    @locale
    @strings
    attr_reader :locale, :strings
    def initialize(locale)
        @locale = locale
        @strings = Hash.new
    end
    
    def addString(key, string)
        @strings[key] = string
    end
    
end

# Test if the specified URL is reachable
def urlReachable?(url)
    begin
        true if open(url)
    rescue
        false
    end
end

docsURL = "https://docs.google.com"
currentDir = File.dirname(__FILE__)
fallbackFileName = "Translations.tsv"
fallbackFilePath = "#{currentDir}/#{fallbackFileName}"
projectDir = ENV["PROJECT_DIR"]
projectName = ENV["PROJECT_NAME"]
outFileBaseDir = projectDir + "/" + projectName
outFileName = "Localizable.strings"

stringsContainers = Array.new
tsvFile = nil

p "Trying GoogleDocs"

unless urlReachable?(docsURL)
    warning = "CAUTION: Using local translations"
    p warning
    system("say #{warning}")
    tsvFile = File.open(fallbackFilePath, "rb")
else
	# Don't allow downloaded files to be created as StringIO. Force a tempfile to be created.
	OpenURI::Buffer.send :remove_const, 'StringMax' if OpenURI::Buffer.const_defined?('StringMax')
	OpenURI::Buffer.const_set 'StringMax', 0
	p "Downloading latest translations"
    tsvFile = open("#{docsURL}/spreadsheets/d/1BhJkfq-iXk9qfcqpT2yd7XxiCn2yrdYlG7Klj5eTLtg/export?format=tsv")
    if FileTest.exist?(fallbackFilePath)
        FileUtils.rm(fallbackFilePath)
    end
    FileUtils.cp(tsvFile.path, fallbackFilePath)
end

tsvFile.each_line { |line|
    locales = line.split("\t")
    key = locales.shift
    if tsvFile.lineno == 1
        locales.each { |locale|
            stringsContainers.push(StringsContainer.new(locale.strip))
        }
    else
        localeIndex = 0
        locales.each { |string|
            stringsContainers[localeIndex].addString(key, string.strip)
            localeIndex += 1
    }
    end
}

stringsContainers.each { |stringContainer|
    locale = stringContainer.locale
    variations = stringContainer.locale.split(',')
    variations.each { |locale|
		strippedLocale = locale.strip
		unless locale.include?("(") then
			localeDir = outFileBaseDir + "/" + locale.strip + ".lproj"
			unless File.directory?(localeDir)
				Dir.mkdir(localeDir)
			end
			out = ""
			stringContainer.strings.each { |key, value|
				value = value.gsub("\"", "\\\"")
				out += "\"#{key}\" = \"#{value}\";\n"
				File.write("#{localeDir}/#{outFileName}", out)
			}
			p "Wrote localizations for #{locale} into #{localeDir}"
		end
    }
}
