abstract class AFilter implements Piper { 
    public float srate; 
    public float rsrate;
    public Piper __reader;
    public AFilter(Piper reader, float srate) { 
      this.srate = srate;
      this.__reader = reader;
      rsrate = 1.0/srate;
    }
    public void randomize() {}
    public void initialize() { }
}



public class CanyonDelay extends AFilter {
  public float ltr_time = 0.5;
  public float rtl_time = 0.5;
  public float ltr_feedback = 0.1;
  public float rtl_feedback = -0.1;
  public float cutoff = 1000.0;
  public Piper reader;
  Pipe buffer = new Pipe(2);
  float[] data_l, data_r;
  int datasize;
  int pos;
  float accum_l, accum_r;
  
  int ltr_offset, rtl_offset;
  float ltr_invmag, rtl_invmag;
  float filter_invmag, filter_mag;
  
  public CanyonDelay(Piper r, float srate) {
    super(r,srate);
      reader = r;
    datasize = (int)(floor(srate)+1);
    data_l = new float[datasize];
    data_r = new float[datasize];
    initialize();
  }
  
  public void initialize() {
    buffer.ridx = buffer.widx = 0;
    pos = 0;
    for(int i=0;i<datasize;i++) {
      data_l[i]=0.0;
      data_r[i]=0.0;
    }
    accum_l = accum_r = 0.0;
    ltr_offset = (int)(ltr_time * srate);
    rtl_offset = (int)(rtl_time * srate);
    ltr_invmag = 1.0 - abs(ltr_feedback);
    rtl_invmag = 1.0 - abs(rtl_feedback);
    filter_invmag = pow(0.5, (4.0 * PI * cutoff * rsrate) );
    filter_mag = 1.0 - filter_invmag;
  }
  
  public String toString() {
    StringBuilder s = new StringBuilder();
    s.append("ltr_time="+ltr_time);
    s.append(", rtl_time="+rtl_time);
    s.append(", ltr_feedback="+ltr_feedback);
    s.append(", rtl_feedback="+rtl_feedback);
    s.append(", cutoff="+cutoff);
    return s.toString();
  }
  
  public void randomize() {
    ltr_time = random(0.001,1);
    rtl_time = random(0.001,1);;
    ltr_feedback = random(-1,1);
    rtl_feedback = random(-1,1);
    cutoff = random(10000);
    initialize();
  }
  
  public float read() {
    if(buffer.ridx==0) {
      float l = reader.read();
      float r = reader.read();
      
      int pos1 = (pos - rtl_offset + datasize) % datasize;
      int pos2 = (pos - ltr_offset + datasize) % datasize;
      
      l = l * rtl_invmag + data_r[pos1] * rtl_feedback;
      r = r * ltr_invmag + data_l[pos2] * ltr_feedback;
      
      l = accum_l * filter_invmag + l * filter_mag;
      r = accum_r * filter_invmag + r * filter_mag;
      
      accum_l = l;
      accum_r = r;
      
      data_l[pos] = l;
      data_r[pos] = r;
      
      buffer.write(l);
      buffer.write(r);
      
      pos=(pos+1)%datasize;
    }
    
    return buffer.read();
  }
}

