import com.theeyetribe.client.*;
import com.theeyetribe.client.data.*;

public class TETSimple
{

  static GazeListener gazeListener;

  public static void main(TETSimple self)
  {
    final GazeManager gm = GazeManager.getInstance();
    boolean success = gm.activate(GazeManager.ApiVersion.VERSION_1_0, GazeManager.ClientMode.PUSH);
    gazeListener = self.new GazeListener();
    gm.addGazeListener(gazeListener);
  }

  public static float getX(TETSimple self) {
    return (float)self.gazeListener.currentOut.x;
  }

  public static float getY(TETSimple self) {
    return (float)self.gazeListener.currentOut.y;
  }

  private class GazeListener implements IGazeListener
  {
    Point2D currentOut = new Point2D();

    @Override
      public void onGazeUpdate(GazeData gazeData)
    {
      currentOut = gazeData.smoothedCoordinates;
      //System.out.println(gazeData.rawCoordinates);
    }
  }
}

