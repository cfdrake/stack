Engine_Stack : CroneEngine {
  var <synth;
  
  *new { arg context, doneCallback;
    ^super.new(context, doneCallback);
  }
  
  alloc {
    synth = {
      arg out, sel;
      
      var input = SoundIn.ar(0);
      var base = 31.5;
      var numFilters = 9;
      
      var filters = Array.fill(numFilters, { | i|
        var index = 2 ** (i + 1);
        var freq = base * index;
        BPF.ar(input, freq, 0.2)
      });
      
      var selected = LinSelectX.ar(sel, filters);
      var final = Pan2.ar(selected, 0);
      
      Out.ar(out, (final).dup);
    }.play(args: [\out, context.out_b], target: context.xg);
  
    this.addCommand("sel", "i", { arg msg;
      synth.set(\sel, msg[1]);
    });
  }
  
  free {
    synth.free;
  }
}
