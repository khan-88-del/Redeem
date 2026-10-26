using UnityEngine;

public class FF_Lighting : MonoBehaviour
{
    void Start()
    {
        // Directional Light setup
        Light sun = FindObjectOfType<Light>();
        if (sun != null)
        {
            sun.type = LightType.Directional;
            sun.intensity = 1.06f;
            sun.shadows = LightShadows.Soft;
            sun.shadowStrength = 0.6f;
            sun.color = new Color(0.97f, 0.97f, 0.97f);
        }

        // Ambient lighting
        RenderSettings.ambientLight = new Color(0.58f, 0.58f, 0.58f);

        // Fog settings
        RenderSettings.fog = true;
        RenderSettings.fogColor = new Color(0.48f, 0.62f, 0.75f);
        RenderSettings.fogMode = FogMode.Linear;
        RenderSettings.fogStartDistance = 50f;
        RenderSettings.fogEndDistance = 1000f;
    }
}
