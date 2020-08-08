Engine_Stack : CroneEngine {
  var <synth;
  
  *new { arg context, doneCallback;
    ^super.new(context, doneCallback);
  }
  
  alloc {
    synth = {
      arg out, sel;
      
      var inputL = SoundIn.ar(0);
      var inputR = SoundIn.ar(1);
      
      var base = 31.5;
      var numFilters = 9;
      
      var filtersL = Array.fill(numFilters, { | i|
        var index = 2 ** (i + 1);
        var freq = base * index;
        BPF.ar(inputL, freq, 0.2)
      });
      
      var filtersR = Array.fill(numFilters, { | i|
        var index = 2 ** (i + 1);
        var freq = base * index;
        BPF.ar(inputR, freq, 0.2)
      });
      
      var selectedL = LinSelectX.ar(sel, filtersL);
      var selectedR = LinSelectX.ar(sel, filtersR);
      
      Out.ar(out, [selectedL, selectedR]);
    }.play(args: [\out, context.out_b], target: context.xg);
  
    this.addCommand("sel", "i", { arg msg;
      synth.set(\sel, msg[1]);
    });
  }
  
  free {
    synth.free;
  }
}
