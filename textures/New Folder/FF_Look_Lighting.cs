using UnityEngine;

public class FF_Look_Lighting : MonoBehaviour
{
    void Start()
    {
        // SUN LIGHT
        Light sun = FindObjectOfType<Light>();
        if (sun != null)
        {
            sun.type = LightType.Directional;
            sun.intensity = 1.15f;
            sun.color = new Color(1.0f, 0.95f, 0.85f); // warm sunlight
            sun.shadows = LightShadows.Soft;
            sun.shadowStrength = 0.65f;
            sun.transform.rotation = Quaternion.Euler(45f, -30f, 0f);
        }

        // AMBIENT LIGHT (cool FF shadows)
        RenderSettings.ambientMode = UnityEngine.Rendering.AmbientMode.Flat;
        RenderSettings.ambientLight = new Color(0.55f, 0.6f, 0.65f);

        // FOG (distance depth)
        RenderSettings.fog = true;
        RenderSettings.fogMode = FogMode.Linear;
        RenderSettings.fogColor = new Color(0.6f, 0.72f, 0.85f);
        RenderSettings.fogStartDistance = 60f;
        RenderSettings.fogEndDistance = 900f;

        // SKY AMBIENT BOOST
        RenderSettings.reflectionIntensity = 1.1f;

        // GLOBAL CONTRAST FEEL
        QualitySettings.shadowDistance = 120f;
    }
}
