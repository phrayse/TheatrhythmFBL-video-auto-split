// Theatrhythm Final Bar Line autosplitter v1.0 by Phrayse
// Automatic splits, load removal.

startup
{
  refreshRate = 20;
  timer.CurrentTimingMethod = TimingMethod.GameTime;
}

init
{
  vars.cooldown = TimeSpan.Zero; // Prevent rapid-fire splits
  vars.clearCooldown = TimeSpan.Zero;
  vars.countHighValuePeriod = 0;
  vars.inHighValuePeriod = false;
  vars.paused = false;
}

split
{
  if (vars.cooldown >= timer.CurrentTime.RealTime.Value)
  {
    return false;
  }

  if (features["stageclear"].current > 87)
  {
    vars.cooldown = timer.CurrentTime.RealTime.Value.Add(new TimeSpan(0,1,0));
    vars.clearCooldown = timer.CurrentTime.RealTime.Value.Add(new TimeSpan(0,0,5)); // Dodge the ~65 value before blackscreen
    vars.countHighValuePeriod = 1; // Account for single blackscreen after stage clear
    return true;
  }
}

isLoading
{
  // pure, unadulterated jank.
  if (features["pauseload"].current > 91.5)
  {
    vars.paused = true;
    if (!vars.inHighValuePeriod) // Only enter this block the first time
    {
      vars.countHighValuePeriod++;
      vars.inHighValuePeriod = true;
    }
  } else {
    if (vars.inHighValuePeriod) // Exit the high-confidence period when value drops below 90
    {
      vars.inHighValuePeriod = false;
    }
  }

  // Title Select screen - not paused.
  if ((vars.clearCooldown < timer.CurrentTime.RealTime.Value) && features["pauseload"].current < 74.9 && features["pauseload"].current > 70)
  {
    vars.countHighValuePeriod = 0;
    vars.paused = false;
  } else if (features["pauseload"].current < 90)
  {
    if (vars.countHighValuePeriod >= 2)
    {
      vars.countHighValuePeriod = 0;
      vars.paused = false;
    }
  }

  // Edit Party screen - not paused.
  if (features["editparty"].current > 90)
  {
    vars.countHighValuePeriod = 1;
    vars.paused = false;
  }

  return vars.paused;
}