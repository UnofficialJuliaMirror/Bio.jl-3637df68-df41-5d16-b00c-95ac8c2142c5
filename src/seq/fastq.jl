# WARNING: This file was generated from fastq.rl using ragel. Do not edit!
# FASTQ sequence types

immutable FASTQ <: FileFormat end


"""
Metadata for FASTQ sequence records containing a `description` field,
and a `quality` string corresponding to the sequence.

Quality scores are stored as integer Phred scores.
"""
type FASTQMetadata
    description::String
    quality::Vector{Int8}

    function FASTQMetadata(description, quality)
        return new(description, quality)
    end

    function FASTQ()
        return new("", Int8[])
    end
end


"A `SeqRecord` for FASTQ sequences"
typealias FASTQSeqRecord DNASeqRecord{FASTQMetadata}

"""
Show a `FASTQSeqRecord` to `io`, with graphical display of quality scores.
"""
function Base.show(io::IO, seqrec::FASTQSeqRecord)
    write(io, "@", seqrec.name, " ", seqrec.metadata.description, "\n")
    for c in seqrec.seq
        show(io, c)
    end
    write(io, '\n')
    # print quality scores as a unicode bar chart
    for q in seqrec.metadata.quality
        if q <= 0
            write(io, '▁')
        elseif q <= 6
            write(io, '▂')
        elseif q <= 12
            write(io, '▃')
        elseif q <= 18
            write(io, '▄')
        elseif q <= 24
            write(io, '▅')
        elseif q <= 30
            write(io, '▆')
        elseif q <= 36
            write(io, '▇')
        else
            write(io, '█')
        end
    end
    write(io, '\n')
end

"""
Write a `FASTQSeqRecord` to `io`, as a valid FASTQ record.
"""
function Base.write(io::IO, seqrec::FASTQSeqRecord; offset::Integer=33,
                    qualheader::Bool=false)
    write(io, "@", seqrec.name, " ", seqrec.metadata.description, "\n")

    for c in seqrec.seq
        show(io, c)
    end
    write(io, "\n")

    if qualheader
        write(io, "+", seqrec.name, " ", seqrec.metadata.description, "\n")
    else
        write(io, "+\n")
    end

    for q in seqrec.metadata.quality
        write(io, char(q + offset))
    end
    write(io, "\n")
end


module FASTQParserImpl

import Bio.Seq: FASTQSeqRecord, QualityEncoding, EMPTY_QUAL_ENCODING
import Bio.Ragel
using Switch
export FASTQParser


const fastq_start  = convert(Int , 25)
const fastq_first_final  = convert(Int , 25)
const fastq_error  = convert(Int , 0)
const fastq_en_main  = convert(Int , 25)

"A type encapsulating the current state of a FASTQ parser"
type FASTQParser
    state::Ragel.State
    seqbuf::Ragel.Buffer{Uint8}
    qualbuf::Ragel.Buffer{Uint8}
    namebuf::String
    descbuf::String
    name2buf::Ragel.Buffer{Uint8}
    desc2buf::Ragel.Buffer{Uint8}
    qualcount::Int
    default_qual_encoding::QualityEncoding

    function FASTQParser(input::Union(IO, String, Vector{Uint8}),
                         default_qual_encoding=EMPTY_QUAL_ENCODING;
                         memory_map::Bool=false)
        cs = fastq_start;
	if memory_map
            if !isa(input, String)
                error("Parser must be given a file name in order to memory map.")
            end
            return new(Ragel.State(cs, input, true),
                       Ragel.Buffer{Uint8}(), Ragel.Buffer{Uint8}(), "", "",
                       Ragel.Buffer{Uint8}(), Ragel.Buffer{Uint8}(), 0,
                       default_qual_encoding)
        else
            return new(Ragel.State(cs, input), Ragel.Buffer{Uint8}(),
                       Ragel.Buffer{Uint8}(), "", "", Ragel.Buffer{Uint8}(),
                       Ragel.Buffer{Uint8}(), 0, default_qual_encoding)
        end
    end
end


function Ragel.ragelstate(parser::FASTQParser)
    return parser.state
end


function accept_state!(input::FASTQParser, output::FASTQSeqRecord)
    if length(input.seqbuf) != length(input.qualbuf)
        error("Error parsing FASTQ: sequence and quality scores must be of equal length")
    end
    output.name = input.namebuf
    output.metadata.description = input.descbuf
    output.seq = DNASequence(input.seqbuf.data, 1, input.seqbuf.pos - 1)

    encoding = infer_quality_encoding(input.qualbuf.data, 1,
                                      input.qualbuf.pos - 1,
                                      input.default_qual_encoding)
    input.default_qual_encoding = encoding
    output.metadata.quality = decode_quality_string(encoding, input.qualbuf.
                                                    1, input.qualbuf.pos - 1)

    empty!(input.seqbuf)
    empty!(input.qualbuf)
end


Ragel.@generate_read_fuction("fastq", FASTQParser, FASTQSeqRecord,
    begin
        @inbounds begin
            if p == pe
	@goto _test_eof

end
@switch cs  begin
    @case 25
@goto st_case_25
@case 0
@goto st_case_0
@case 1
@goto st_case_1
@case 2
@goto st_case_2
@case 3
@goto st_case_3
@case 4
@goto st_case_4
@case 5
@goto st_case_5
@case 6
@goto st_case_6
@case 7
@goto st_case_7
@case 8
@goto st_case_8
@case 9
@goto st_case_9
@case 10
@goto st_case_10
@case 11
@goto st_case_11
@case 12
@goto st_case_12
@case 26
@goto st_case_26
@case 13
@goto st_case_13
@case 14
@goto st_case_14
@case 15
@goto st_case_15
@case 16
@goto st_case_16
@case 27
@goto st_case_27
@case 28
@goto st_case_28
@case 17
@goto st_case_17
@case 18
@goto st_case_18
@case 19
@goto st_case_19
@case 20
@goto st_case_20
@case 21
@goto st_case_21
@case 22
@goto st_case_22
@case 23
@goto st_case_23
@case 24
@goto st_case_24

end
@goto st_out
@label ctr52
	input.state.linenum += 1

@goto st25
@label st25
p+= 1;
	if p == pe
	@goto _test_eof25

end
@label st_case_25
@switch ( data[1 + p ])  begin
    @case 9
@goto st25
@case 10
@goto ctr52
@case 32
@goto st25
@case 64
ck  = convert(Int , 0)

if (length(input.qualbuf) == length(input.seqbuf)
    )
	ck += 1;

end
if 1 <= ck
	@goto st1

end
@goto st0

end
if 11 <= ( data[1 + p ]) && ( data[1 + p ]) <= 13
	@goto st25

end
@goto st0
@label st_case_0
@label st0
cs = 0;
	@goto _out
@label ctr54
	yield = true;
        	p+= 1; cs = 1; @goto _out



@goto st1
@label st1
p+= 1;
	if p == pe
	@goto _test_eof1

end
@label st_case_1
if ( data[1 + p ]) == 32
	@goto st0

end
if ( data[1 + p ]) < 14
	if 9 <= ( data[1 + p ])
	@goto st0

end

elseif ( ( data[1 + p ]) > 31  )
	if 33 <= ( data[1 + p ])
	@goto ctr0

end

else
	@goto ctr0

end
@goto ctr0
@label ctr0
	Ragel.@pushmark!
@goto st2
@label st2
p+= 1;
	if p == pe
	@goto _test_eof2

end
@label st_case_2
@switch ( data[1 + p ])  begin
    @case 9
@goto ctr3
@case 10
@goto ctr4
@case 11
@goto ctr3
@case 12
@goto st0
@case 13
@goto ctr5
@case 32
@goto ctr3

end
if ( data[1 + p ]) > 31
	if 33 <= ( data[1 + p ])
	@goto st2

end

elseif ( ( data[1 + p ]) >= 14  )
	@goto st2

end
@goto st2
@label ctr3
	input.namebuf = Ragel.@asciistring_from_mark!
@goto st3
@label st3
p+= 1;
	if p == pe
	@goto _test_eof3

end
@label st_case_3
@switch ( data[1 + p ])  begin
    @case 9
@goto st3
@case 11
@goto st3
@case 32
@goto st3

end
if ( data[1 + p ]) < 14
	if 10 <= ( data[1 + p ])
	@goto st0

end

elseif ( ( data[1 + p ]) > 31  )
	if 33 <= ( data[1 + p ])
	@goto ctr6

end

else
	@goto ctr6

end
@goto ctr6
@label ctr6
	Ragel.@pushmark!
@goto st4
@label st4
p+= 1;
	if p == pe
	@goto _test_eof4

end
@label st_case_4
@switch ( data[1 + p ])  begin
    @case 10
@goto ctr9
@case 13
@goto ctr10

end
if ( data[1 + p ]) > 12
	if 14 <= ( data[1 + p ])
	@goto st4

end

elseif ( ( data[1 + p ]) >= 11  )
	@goto st4

end
@goto st4
@label ctr4
	input.namebuf = Ragel.@asciistring_from_mark!
	input.state.linenum += 1

@goto st5
@label ctr9
	input.descbuf = Ragel.@asciistring_from_mark!
	input.state.linenum += 1

@goto st5
@label ctr50
	input.state.linenum += 1

@goto st5
@label st5
p+= 1;
	if p == pe
	@goto _test_eof5

end
@label st_case_5
@switch ( data[1 + p ])  begin
    @case 10
@goto ctr11
@case 13
@goto st7

end
if 65 <= ( data[1 + p ]) && ( data[1 + p ]) <= 122
	@goto ctr13

end
@goto st0
@label ctr11
	input.state.linenum += 1

@goto st6
@label ctr43
	append!(input.seqbuf, state.buffer, (Ragel.@popmark!), p)
	input.state.linenum += 1

@goto st6
@label st6
p+= 1;
	if p == pe
	@goto _test_eof6

end
@label st_case_6
@switch ( data[1 + p ])  begin
    @case 10
@goto ctr11
@case 13
@goto st7
@case 43
@goto st8

end
if 65 <= ( data[1 + p ]) && ( data[1 + p ]) <= 122
	@goto ctr13

end
@goto st0
@label ctr44
	append!(input.seqbuf, state.buffer, (Ragel.@popmark!), p)
@goto st7
@label st7
p+= 1;
	if p == pe
	@goto _test_eof7

end
@label st_case_7
if ( data[1 + p ]) == 10
	@goto ctr11

end
@goto st0
@label st8
p+= 1;
	if p == pe
	@goto _test_eof8

end
@label st_case_8
@switch ( data[1 + p ])  begin
    @case 10
@goto ctr16
@case 13
@goto st23
@case 32
@goto st0

end
if ( data[1 + p ]) < 14
	if 9 <= ( data[1 + p ]) && ( data[1 + p ]) <= 12
	@goto st0

end

elseif ( ( data[1 + p ]) > 31  )
	if 33 <= ( data[1 + p ])
	@goto ctr15

end

else
	@goto ctr15

end
@goto ctr15
@label ctr15
	Ragel.@pushmark!
@goto st9
@label st9
p+= 1;
	if p == pe
	@goto _test_eof9

end
@label st_case_9
@switch ( data[1 + p ])  begin
    @case 9
@goto ctr19
@case 10
@goto ctr20
@case 11
@goto ctr19
@case 12
@goto st0
@case 13
@goto ctr21
@case 32
@goto ctr19

end
if ( data[1 + p ]) > 31
	if 33 <= ( data[1 + p ])
	@goto st9

end

elseif ( ( data[1 + p ]) >= 14  )
	@goto st9

end
@goto st9
@label ctr19
	append!(input.name2buf, state.buffer, (Ragel.@popmark!), p)
@goto st10
@label st10
p+= 1;
	if p == pe
	@goto _test_eof10

end
@label st_case_10
@switch ( data[1 + p ])  begin
    @case 9
@goto st10
@case 11
@goto st10
@case 32
@goto st10

end
if ( data[1 + p ]) < 14
	if 10 <= ( data[1 + p ])
	@goto st0

end

elseif ( ( data[1 + p ]) > 31  )
	if 33 <= ( data[1 + p ])
	@goto ctr22

end

else
	@goto ctr22

end
@goto ctr22
@label ctr22
	Ragel.@pushmark!
@goto st11
@label st11
p+= 1;
	if p == pe
	@goto _test_eof11

end
@label st_case_11
@switch ( data[1 + p ])  begin
    @case 10
@goto ctr25
@case 13
@goto ctr26

end
if ( data[1 + p ]) > 12
	if 14 <= ( data[1 + p ])
	@goto st11

end

elseif ( ( data[1 + p ]) >= 11  )
	@goto st11

end
@goto st11
@label ctr16
	input.state.linenum += 1

@goto st12
@label ctr20
	append!(input.name2buf, state.buffer, (Ragel.@popmark!), p)
	input.state.linenum += 1

@goto st12
@label ctr25
	append!(input.desc2buf, state.buffer, (Ragel.@popmark!), p)
	input.state.linenum += 1

@goto st12
@label st12
p+= 1;
	if p == pe
	@goto _test_eof12

end
@label st_case_12
@switch ( data[1 + p ])  begin
    @case 10
@goto ctr27
@case 13
@goto st13

end
if 33 <= ( data[1 + p ]) && ( data[1 + p ]) <= 126
	ck  = convert(Int , 0)

if (length(input.qualbuf) + input.qualcount < length(input.seqbuf)
    )
	ck += 1;

end
if 1 <= ck
	@goto ctr29

end
@goto st0

end
@goto st0
@label ctr27
	input.state.linenum += 1

@goto st26
@label ctr30
	append!(input.qualbuf, state.buffer, (Ragel.@popmark!), p)
        input.qualcount = 0

	input.state.linenum += 1

@goto st26
@label ctr38
	input.state.linenum += 1

	append!(input.qualbuf, state.buffer, (Ragel.@popmark!), p)
        input.qualcount = 0

@goto st26
@label ctr40
	append!(input.name2buf, state.buffer, (Ragel.@popmark!), p)
	input.state.linenum += 1

	append!(input.qualbuf, state.buffer, (Ragel.@popmark!), p)
        input.qualcount = 0

@goto st26
@label st26
p+= 1;
	if p == pe
	@goto _test_eof26

end
@label st_case_26
@switch ( data[1 + p ])  begin
    @case 10
@goto ctr27
@case 13
@goto st13
@case 64
ck  = convert(Int , 0)

if (length(input.qualbuf) + input.qualcount < length(input.seqbuf)
    )
	ck += 1;

end
if (length(input.qualbuf) == length(input.seqbuf)
    )
	ck += 2;

end
if ck < 2
	if 1 <= ck
	@goto ctr29

end

elseif ( ck > 2  )
	@goto ctr55

else
	@goto ctr54

end
@goto st0

end
if ( data[1 + p ]) > 63
	if 65 <= ( data[1 + p ]) && ( data[1 + p ]) <= 126
	ck  = convert(Int , 0)

if (length(input.qualbuf) + input.qualcount < length(input.seqbuf)
    )
	ck += 1;

end
if 1 <= ck
	@goto ctr29

end
@goto st0

end

elseif ( ( data[1 + p ]) >= 33  )
	ck  = convert(Int , 0)

if (length(input.qualbuf) + input.qualcount < length(input.seqbuf)
    )
	ck += 1;

end
if 1 <= ck
	@goto ctr29

end
@goto st0

end
@goto st0
@label ctr31
	append!(input.qualbuf, state.buffer, (Ragel.@popmark!), p)
        input.qualcount = 0

@goto st13
@label ctr41
	append!(input.name2buf, state.buffer, (Ragel.@popmark!), p)
	append!(input.qualbuf, state.buffer, (Ragel.@popmark!), p)
        input.qualcount = 0

@goto st13
@label st13
p+= 1;
	if p == pe
	@goto _test_eof13

end
@label st_case_13
if ( data[1 + p ]) == 10
	@goto ctr27

end
@goto st0
@label ctr29
	Ragel.@pushmark!
	input.qualcount += 1

@goto st14
@label ctr32
	input.qualcount += 1

@goto st14
@label st14
p+= 1;
	if p == pe
	@goto _test_eof14

end
@label st_case_14
@switch ( data[1 + p ])  begin
    @case 10
@goto ctr30
@case 13
@goto ctr31

end
if 33 <= ( data[1 + p ]) && ( data[1 + p ]) <= 126
	ck  = convert(Int , 0)

if (length(input.qualbuf) + input.qualcount < length(input.seqbuf)
    )
	ck += 1;

end
if 1 <= ck
	@goto ctr32

end
@goto st0

end
@goto st0
@label ctr55
	Ragel.@pushmark!
	input.qualcount += 1

	yield = true;
        	p+= 1; cs = 15; @goto _out



@goto st15
@label st15
p+= 1;
	if p == pe
	@goto _test_eof15

end
@label st_case_15
@switch ( data[1 + p ])  begin
    @case 10
@goto ctr30
@case 13
@goto ctr31
@case 32
@goto st0
@case 127
@goto ctr0

end
if ( data[1 + p ]) < 14
	if 9 <= ( data[1 + p ]) && ( data[1 + p ]) <= 12
	@goto st0

end

elseif ( ( data[1 + p ]) > 31  )
	if 33 <= ( data[1 + p ]) && ( data[1 + p ]) <= 126
	ck  = convert(Int , 0)

if (length(input.qualbuf) + input.qualcount < length(input.seqbuf)
    )
	ck += 1;

end
if ck > 0
	@goto ctr33

else
	@goto ctr0

end
@goto st0

end

else
	@goto ctr0

end
@goto ctr0
@label ctr33
	Ragel.@pushmark!
	input.qualcount += 1

@goto st16
@label ctr36
	input.qualcount += 1

@goto st16
@label st16
p+= 1;
	if p == pe
	@goto _test_eof16

end
@label st_case_16
@switch ( data[1 + p ])  begin
    @case 9
@goto ctr3
@case 10
@goto ctr34
@case 11
@goto ctr3
@case 12
@goto st0
@case 13
@goto ctr35
@case 32
@goto ctr3
@case 127
@goto st2

end
if ( data[1 + p ]) > 31
	if 33 <= ( data[1 + p ]) && ( data[1 + p ]) <= 126
	ck  = convert(Int , 0)

if (length(input.qualbuf) + input.qualcount < length(input.seqbuf)
    )
	ck += 1;

end
if ck > 0
	@goto ctr36

else
	@goto st2

end
@goto st0

end

elseif ( ( data[1 + p ]) >= 14  )
	@goto st2

end
@goto st2
@label ctr49
	input.state.linenum += 1

@goto st27
@label ctr34
	input.namebuf = Ragel.@asciistring_from_mark!
	input.state.linenum += 1

	append!(input.qualbuf, state.buffer, (Ragel.@popmark!), p)
        input.qualcount = 0

@goto st27
@label st27
p+= 1;
	if p == pe
	@goto _test_eof27

end
@label st_case_27
@switch ( data[1 + p ])  begin
    @case 10
@goto ctr37
@case 13
@goto st17
@case 64
ck  = convert(Int , 0)

if (length(input.qualbuf) + input.qualcount < length(input.seqbuf)
    )
	ck += 1;

end
if (length(input.qualbuf) == length(input.seqbuf)
    )
	ck += 2;

end
if ck < 2
	if 1 <= ck
	@goto ctr29

end

elseif ( ck > 2  )
	@goto ctr55

else
	@goto ctr54

end
@goto st0

end
if ( data[1 + p ]) < 65
	if 33 <= ( data[1 + p ]) && ( data[1 + p ]) <= 63
	ck  = convert(Int , 0)

if (length(input.qualbuf) + input.qualcount < length(input.seqbuf)
    )
	ck += 1;

end
if 1 <= ck
	@goto ctr29

end
@goto st0

end

elseif ( ( data[1 + p ]) > 122  )
	if ( data[1 + p ]) <= 126
	ck  = convert(Int , 0)

if (length(input.qualbuf) + input.qualcount < length(input.seqbuf)
    )
	ck += 1;

end
if 1 <= ck
	@goto ctr29

end
@goto st0

end

else
	ck  = convert(Int , 0)

if (length(input.qualbuf) + input.qualcount < length(input.seqbuf)
    )
	ck += 1;

end
if ck > 0
	@goto ctr57

else
	@goto ctr13

end
@goto st0

end
@goto st0
@label ctr37
	input.state.linenum += 1

@goto st28
@label ctr46
	append!(input.seqbuf, state.buffer, (Ragel.@popmark!), p)
	input.state.linenum += 1

	append!(input.qualbuf, state.buffer, (Ragel.@popmark!), p)
        input.qualcount = 0

@goto st28
@label st28
p+= 1;
	if p == pe
	@goto _test_eof28

end
@label st_case_28
@switch ( data[1 + p ])  begin
    @case 10
@goto ctr37
@case 13
@goto st17
@case 43
ck  = convert(Int , 0)

if (length(input.qualbuf) + input.qualcount < length(input.seqbuf)
    )
	ck += 1;

end
if ck > 0
	@goto ctr58

else
	@goto st8

end
@goto st0
@case 64
ck  = convert(Int , 0)

if (length(input.qualbuf) + input.qualcount < length(input.seqbuf)
    )
	ck += 1;

end
if (length(input.qualbuf) == length(input.seqbuf)
    )
	ck += 2;

end
if ck < 2
	if 1 <= ck
	@goto ctr29

end

elseif ( ck > 2  )
	@goto ctr55

else
	@goto ctr54

end
@goto st0

end
if ( data[1 + p ]) < 44
	if 33 <= ( data[1 + p ]) && ( data[1 + p ]) <= 42
	ck  = convert(Int , 0)

if (length(input.qualbuf) + input.qualcount < length(input.seqbuf)
    )
	ck += 1;

end
if 1 <= ck
	@goto ctr29

end
@goto st0

end

elseif ( ( data[1 + p ]) > 63  )
	if ( data[1 + p ]) > 122
	if ( data[1 + p ]) <= 126
	ck  = convert(Int , 0)

if (length(input.qualbuf) + input.qualcount < length(input.seqbuf)
    )
	ck += 1;

end
if 1 <= ck
	@goto ctr29

end
@goto st0

end

elseif ( ( data[1 + p ]) >= 65  )
	ck  = convert(Int , 0)

if (length(input.qualbuf) + input.qualcount < length(input.seqbuf)
    )
	ck += 1;

end
if ck > 0
	@goto ctr57

else
	@goto ctr13

end
@goto st0

end

else
	ck  = convert(Int , 0)

if (length(input.qualbuf) + input.qualcount < length(input.seqbuf)
    )
	ck += 1;

end
if 1 <= ck
	@goto ctr29

end
@goto st0

end
@goto st0
@label ctr47
	append!(input.seqbuf, state.buffer, (Ragel.@popmark!), p)
	append!(input.qualbuf, state.buffer, (Ragel.@popmark!), p)
        input.qualcount = 0

@goto st17
@label st17
p+= 1;
	if p == pe
	@goto _test_eof17

end
@label st_case_17
if ( data[1 + p ]) == 10
	@goto ctr37

end
@goto st0
@label ctr58
	Ragel.@pushmark!
	input.qualcount += 1

@goto st18
@label st18
p+= 1;
	if p == pe
	@goto _test_eof18

end
@label st_case_18
@switch ( data[1 + p ])  begin
    @case 10
@goto ctr38
@case 13
@goto ctr31
@case 32
@goto st0
@case 127
@goto ctr15

end
if ( data[1 + p ]) < 14
	if 9 <= ( data[1 + p ]) && ( data[1 + p ]) <= 12
	@goto st0

end

elseif ( ( data[1 + p ]) > 31  )
	if 33 <= ( data[1 + p ]) && ( data[1 + p ]) <= 126
	ck  = convert(Int , 0)

if (length(input.qualbuf) + input.qualcount < length(input.seqbuf)
    )
	ck += 1;

end
if ck > 0
	@goto ctr39

else
	@goto ctr15

end
@goto st0

end

else
	@goto ctr15

end
@goto ctr15
@label ctr39
	Ragel.@pushmark!
	input.qualcount += 1

@goto st19
@label ctr42
	input.qualcount += 1

@goto st19
@label st19
p+= 1;
	if p == pe
	@goto _test_eof19

end
@label st_case_19
@switch ( data[1 + p ])  begin
    @case 9
@goto ctr19
@case 10
@goto ctr40
@case 11
@goto ctr19
@case 12
@goto st0
@case 13
@goto ctr41
@case 32
@goto ctr19
@case 127
@goto st9

end
if ( data[1 + p ]) > 31
	if 33 <= ( data[1 + p ]) && ( data[1 + p ]) <= 126
	ck  = convert(Int , 0)

if (length(input.qualbuf) + input.qualcount < length(input.seqbuf)
    )
	ck += 1;

end
if ck > 0
	@goto ctr42

else
	@goto st9

end
@goto st0

end

elseif ( ( data[1 + p ]) >= 14  )
	@goto st9

end
@goto st9
@label ctr13
	Ragel.@pushmark!
@goto st20
@label st20
p+= 1;
	if p == pe
	@goto _test_eof20

end
@label st_case_20
@switch ( data[1 + p ])  begin
    @case 10
@goto ctr43
@case 13
@goto ctr44

end
if 65 <= ( data[1 + p ]) && ( data[1 + p ]) <= 122
	@goto st20

end
@goto st0
@label ctr57
	Ragel.@pushmark!
	input.qualcount += 1

@goto st21
@label ctr48
	input.qualcount += 1

@goto st21
@label st21
p+= 1;
	if p == pe
	@goto _test_eof21

end
@label st_case_21
@switch ( data[1 + p ])  begin
    @case 10
@goto ctr46
@case 13
@goto ctr47

end
if ( data[1 + p ]) < 65
	if 33 <= ( data[1 + p ])
	ck  = convert(Int , 0)

if (length(input.qualbuf) + input.qualcount < length(input.seqbuf)
    )
	ck += 1;

end
if 1 <= ck
	@goto ctr32

end
@goto st0

end

elseif ( ( data[1 + p ]) > 122  )
	if ( data[1 + p ]) <= 126
	ck  = convert(Int , 0)

if (length(input.qualbuf) + input.qualcount < length(input.seqbuf)
    )
	ck += 1;

end
if 1 <= ck
	@goto ctr32

end
@goto st0

end

else
	ck  = convert(Int , 0)

if (length(input.qualbuf) + input.qualcount < length(input.seqbuf)
    )
	ck += 1;

end
if ck > 0
	@goto ctr48

else
	@goto st20

end
@goto st0

end
@goto st0
@label ctr35
	input.namebuf = Ragel.@asciistring_from_mark!
	append!(input.qualbuf, state.buffer, (Ragel.@popmark!), p)
        input.qualcount = 0

@goto st22
@label st22
p+= 1;
	if p == pe
	@goto _test_eof22

end
@label st_case_22
if ( data[1 + p ]) == 10
	@goto ctr49

end
@goto st0
@label ctr21
	append!(input.name2buf, state.buffer, (Ragel.@popmark!), p)
@goto st23
@label ctr26
	append!(input.desc2buf, state.buffer, (Ragel.@popmark!), p)
@goto st23
@label st23
p+= 1;
	if p == pe
	@goto _test_eof23

end
@label st_case_23
if ( data[1 + p ]) == 10
	@goto ctr16

end
@goto st0
@label ctr5
	input.namebuf = Ragel.@asciistring_from_mark!
@goto st24
@label ctr10
	input.descbuf = Ragel.@asciistring_from_mark!
@goto st24
@label st24
p+= 1;
	if p == pe
	@goto _test_eof24

end
@label st_case_24
if ( data[1 + p ]) == 10
	@goto ctr50

end
@goto st0
@label st_out
@label _test_eof25
cs = 25; @goto _test_eof
@label _test_eof1
cs = 1; @goto _test_eof
@label _test_eof2
cs = 2; @goto _test_eof
@label _test_eof3
cs = 3; @goto _test_eof
@label _test_eof4
cs = 4; @goto _test_eof
@label _test_eof5
cs = 5; @goto _test_eof
@label _test_eof6
cs = 6; @goto _test_eof
@label _test_eof7
cs = 7; @goto _test_eof
@label _test_eof8
cs = 8; @goto _test_eof
@label _test_eof9
cs = 9; @goto _test_eof
@label _test_eof10
cs = 10; @goto _test_eof
@label _test_eof11
cs = 11; @goto _test_eof
@label _test_eof12
cs = 12; @goto _test_eof
@label _test_eof26
cs = 26; @goto _test_eof
@label _test_eof13
cs = 13; @goto _test_eof
@label _test_eof14
cs = 14; @goto _test_eof
@label _test_eof15
cs = 15; @goto _test_eof
@label _test_eof16
cs = 16; @goto _test_eof
@label _test_eof27
cs = 27; @goto _test_eof
@label _test_eof28
cs = 28; @goto _test_eof
@label _test_eof17
cs = 17; @goto _test_eof
@label _test_eof18
cs = 18; @goto _test_eof
@label _test_eof19
cs = 19; @goto _test_eof
@label _test_eof20
cs = 20; @goto _test_eof
@label _test_eof21
cs = 21; @goto _test_eof
@label _test_eof22
cs = 22; @goto _test_eof
@label _test_eof23
cs = 23; @goto _test_eof
@label _test_eof24
cs = 24; @goto _test_eof
@label _test_eof
if p == eof
	@switch cs  begin
    @case 26
@case 27
@case 28
	yield = true;
        	p+= 1; cs = 0; @goto _out




	break;

end

end
@label _out
end
    end,
    begin
        accept_state!(input, output)
    end)

end # module FASTQParserImpl


using Bio.Seq.FASTQParserImpl

"An iterator over entries in a FASTQ file or stream"
type FASTQIterator
    parser::FASTQParser

    # A type or function used to construct output sequence types
    default_qual_encoding::QualityEncoding
    isdone::Bool
    nextitem
end

"""
Parse a FASTQ file.

# Arguments
  * `filename::String`: Path of the FASTA file.
  * `qual_encoding::QualityEncoding`: assumed quality score encoding
    (Default: EMPTY_QUAL_ENCODING, i.e. no assumption)
  * `memory_map::Bool`: If true, attempt to memory map the file on supported
    platforms. (Default: `false`)

# Returns
An iterator over `SeqRecord`s contained in the file.
"""
function Base.read(filename::String, ::Type{FASTQ},
                   qual_encoding::QualityEncoding=EMPTY_QUAL_ENCODING;
                   memory_map=false)
    return FASTQIterator(FASTQParser(filename, memory_map=memory_map),
                         qual_encoding, false, nothing)
end

"""
Parse a FASTQ file.

# Arguments
  * `input::IO`: Input stream containing FASTQ data.
  * `qual_encoding::QualityEncoding`: assumed quality score encoding
    (Default: EMPTY_QUAL_ENCODING, i.e. no assumption)

# Returns
An iterator over `SeqRecord`s contained in the file.
"""
function Base.read(input::IO, ::Type{FASTQ},
                   qual_encoding::QualityEncoding=EMPTY_QUAL_ENCODING)
    return FASTQIterator(FASTQParser(input), qual_encoding, false, nothing)
end


function Base.read(input::Cmd, ::Type{FASTQ},
                   qual_encoding::QualityEncoding=EMPTY_QUAL_ENCODING)
    return FASTQIterator(FASTQParser(open(input, "r")[1]), qual_encoding, false, nothing)
end


function advance!(it::FASTQIterator)
    it.isdone = !FASTQParserImpl.advance!(it.parser)
    if !it.isdone
        if length(it.parser.seqbuf) != length(it.parser.qualbuf)
            error("Error parsing FASTQ: sequence and quality scores must be of equal length")
        end
        encoding = infer_quality_encoding(it.parser.qualbuf.data, 1,
                                          it.parser.qualbuf.pos - 1,
                                          it.default_qual_encoding)
        it.default_qual_encoding = encoding
        qscores = decode_quality_string(encoding, it.parser.qualbuf.data,
                                        1, it.parser.qualbuf.pos - 1)

        if (!isempty(it.parser.name2buf) && it.parser.name2buf != it.parser.namebuf) ||
           (!isempty(it.parser.desc2buf) && it.parser.desc2buf != it.parser.descbuf)
            error("Error parsing FASTQ: sequence and quality scores have non-matching identifiers")
        end

        it.nextitem =
            FASTQSeqRecord(it.parser.namebuf,
                           DNASequence(it.parser.seqbuf.data, 1, it.parser.seqbuf.pos - 1),
                           FASTQMetadata(it.parser.descbuf, qscores))

        empty!(it.parser.seqbuf)
        empty!(it.parser.qualbuf)
        empty!(it.parser.name2buf)
        empty!(it.parser.desc2buf)
    end
end


function start(it::FASTQIterator)
    advance!(it)
    return nothing
end


function next(it::FASTQIterator, state)
    item = it.nextitem
    advance!(it)
    return item, nothing
end


function done(it::FASTQIterator, state)
    return it.isdone
end
