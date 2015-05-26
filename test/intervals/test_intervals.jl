module TestIntervals

using FactCheck
using Distributions
using Bio
using Bio.Intervals


# Generate an array of n random Interval{Int} object. With sequence names
# samples from seqnames, and intervals drawn to lie in [1, maxpos].
function random_intervals(seqnames, maxpos::Int, n::Int)
    seq_dist = Categorical(length(seqnames))
    strand_dist = Categorical(2)
    length_dist = Normal(1000, 1000)

    intervals = Array(Interval{Int}, n)
    for i in 1:n
        intlen = ceil(Int, rand(length_dist))
        first = rand(1:maxpos-intlen)
        last = first + intlen - 1
        strand = rand(strand_dist) == 1 ? STRAND_POS : STRAND_NEG
        intervals[i] = Interval{Int}(seqnames[rand(seq_dist)],
                                     first, last, strand, i)
    end
    return intervals
end


# A simple interval intersection implementation to test against.
function simple_intersection(intervals_a, intervals_b)
    sort!(intervals_a)
    sort!(intervals_b)

    intersections = Any[]

    i = 1
    j = 1
    while i <= length(intervals_a) && j <= length(intervals_b)
        ai = intervals_a[i]
        bj = intervals_b[j]

        if Intervals.alphanum_isless(ai.seqname, bj.seqname) ||
           (ai.seqname == bj.seqname && ai.last < bj.first)
            i += 1
        elseif Intervals.alphanum_isless(bj.seqname, ai.seqname) ||
               (ai.seqname == bj.seqname && bj.last < ai.first)
            j += 1
        else
            k = j
            while k <= length(intervals_b) && intervals_b[k].first <= ai.last
                if isoverlapping(ai, intervals_b[k])
                    push!(intersections, (ai, intervals_b[k]))
                end
                k += 1
            end
            i += 1
        end
    end

    return intersections
end


facts("IntervalCollection") do

    context("Insertion/Iteration") do
        n = 100000
        intervals = random_intervals(["one", "two", "three"], 1000000, n)
        ic = IntervalCollection{Int}()

        @fact isempty(ic) => true
        @fact collect(Interval{Int}, ic) == Interval{Int}[] => true

        for interval in intervals
            push!(ic, interval)
        end
        @fact collect(ic) == sort(intervals) => true
    end


    context("Intersection") do
        n = 1000
        srand(1234)
        intervals_a = random_intervals(["one", "two", "three"], 1000000, n)
        intervals_b = random_intervals(["one", "three", "four"], 1000000, n)

        # empty versus empty
        ic_a = IntervalCollection{Int}()
        ic_b = IntervalCollection{Int}()
        @fact collect(intersect(ic_a, ic_b)) == Any[] => true

        # empty versus non-empty
        for interval in intervals_a
            push!(ic_a, interval)
        end

        @fact collect(intersect(ic_a, ic_b)) == Any[] => true
        @fact collect(intersect(ic_b, ic_a)) == Any[] => true

        # non-empty versus non-empty
        for interval in intervals_b
            push!(ic_b, interval)
        end

        @fact sort(collect(intersect(ic_a, ic_b))) ==
              sort(simple_intersection(intervals_a, intervals_b)) => true
    end


    context("Show") do
        nullout = open("/dev/null", "w")

        ic = IntervalCollection{Int}()
        show(nullout, ic)

        push!(ic, Interval{Int}("one", 1, 1000, STRAND_POS, 0))
        show(nullout, ic)

        intervals = random_intervals(["one", "two", "three"], 1000000, 100)
        for interval in intervals
            push!(ic, interval)
        end
        show(nullout, ic)

        show(nullout, STRAND_NA)
        show(nullout, STRAND_POS)
        show(nullout, STRAND_NEG)
        show(nullout, STRAND_BOTH)
    end
end


facts("Alphanumeric Sorting") do
    @fact sort(["b", "c" ,"a"], lt=Intervals.alphanum_isless) => ["a", "b", "c"]
    @fact sort(["a10", "a2" ,"a1"], lt=Intervals.alphanum_isless) => ["a1", "a2", "a10"]
    @fact sort(["a10a", "a2c" ,"a3b"], lt=Intervals.alphanum_isless) => ["a2c", "a3b", "a10a"]
    @fact sort(["a3c", "a3b" ,"a3a"], lt=Intervals.alphanum_isless) => ["a3a", "a3b", "a3c"]
    @fact sort(["a1ac", "a1aa" ,"a1ab"], lt=Intervals.alphanum_isless) => ["a1aa", "a1ab", "a1ac"]

    @fact Intervals.alphanum_isless("aa", "aa1") => true
    @fact Intervals.alphanum_isless("aa1", "aa") => false

    @fact sort(["ac3", "aa", "ab", "aa1", "ac", "ab2"], lt=Intervals.alphanum_isless) =>
        ["aa", "aa1", "ab", "ab2", "ac", "ac3"]
end


facts("IntervalStream") do
    context("StreamBuffer") do
        ref = Int[]
        sb = Intervals.StreamBuffer{Int}()
        @fact isempty(sb) => true
        @fact length(sb) == 0 => true
        @fact_throws shift!(sb)

        ref_shifts = Int[]
        sb_shifts = Int[]

        for i in 1:10000
            if !isempty(ref) && rand() < 0.3
                push!(ref_shifts, shift!(ref))
                push!(sb_shifts, shift!(sb))
            else
                x = rand(Int)
                push!(ref, x)
                push!(sb, x)
            end
        end

        @fact length(sb) == length(ref) => true
        @fact [sb[i] for i in 1:length(sb)] == ref => true
        @fact ref_shifts == sb_shifts => true
        @fact_throws sb[0]
        @fact_throws sb[length(sb) + 1]
    end

    context("Intersection") do
        n = 1000
        srand(1234)
        intervals_a = random_intervals(["one", "two", "three"], 1000000, n)
        intervals_b = random_intervals(["one", "three", "four"], 1000000, n)

        ic_a = IntervalCollection{Int}()
        ic_b = IntervalCollection{Int}()

        for interval in intervals_a
            push!(ic_a, interval)
        end

        for interval in intervals_b
            push!(ic_b, interval)
        end

        # non-empty versus non-empty, stream intersection
        it = Intervals.IntervalStreamIntersectIterator{Int, Int}(
                ic_a, ic_b, Intervals.alphanum_isless)

        @fact sort(collect(it)) ==
              sort(simple_intersection(intervals_a, intervals_b)) => true

        # Interesction edge cases: skipping over whole sequences
        it = Intervals.IntervalStreamIntersectIterator{Nothing, Nothing}(
            [Interval("a", 1, 100, STRAND_POS, nothing), Interval("c", 1, 100, STRAND_POS, nothing)],
            [Interval("a", 1, 100, STRAND_POS, nothing), Interval("b", 1, 100, STRAND_POS, nothing)],
            isless)
        @fact length(collect(it)) => 1

        it = Intervals.IntervalStreamIntersectIterator{Nothing, Nothing}(
            [Interval("c", 1, 100, STRAND_POS, nothing), Interval("d", 1, 100, STRAND_POS, nothing)],
            [Interval("b", 1, 100, STRAND_POS, nothing), Interval("d", 1, 100, STRAND_POS, nothing)],
            isless)
        @fact length(collect(it)) => 1

        # unsorted streams are not allowed
        @fact_throws begin
            it = Intervals.IntervalStreamIntersectIterator{Nothing, Nothing}(
                [Interval("b", 1, 1000, STRAND_POS, nothing),
                 Interval("a", 1, 1000, STRAND_POS, nothing)],
                [Interval("a", 1, 1000, STRAND_POS, nothing),
                 Interval("b", 1, 1000, STRAND_POS, nothing)], isless)
            collect(it)
        end

        @fact_throws begin
            it = Intervals.IntervalStreamIntersectIterator{Nothing, Nothing}(
                [Interval("a", 1, 1000, STRAND_POS, nothing),
                 Interval("a", 500, 1000, STRAND_POS, nothing),
                 Interval("a", 400, 2000, STRAND_POS, nothing)],
                [Interval("a", 1, 1000, STRAND_POS, nothing),
                 Interval("b", 1, 1000, STRAND_POS, nothing)], isless)
            collect(it)
        end
    end
end


end # module TestIntervals

