using UnityEngine;

public class FFLightFromPhoto : MonoBehaviour
{
    void Start()
    {
        // Sun light
        Light sun = FindObjectOfType<Light>();

        if (sun == null)
        {
            GameObject go = new GameObject("FF Sun");
            sun = go.AddComponent<Light>();
        }

        // Intensity = 1.06
        sun.type = LightType.Directional;
        sun.intensity = 1.06f;

        // Light color #F8F8F8
        sun.color = new Color(0.97f, 0.97f, 0.97f);

        // Shadows = 0.6 feel
        sun.shadows = LightShadows.Soft;
        sun.shadowStrength = 0.6f;

        // Darkness ≈ ambient darker tone
        RenderSettings.ambientLight = new Color(0.59f, 0.59f, 0.59f) * 0.97f;

        // Fog (photo values)
        RenderSettings.fog = true;
        RenderSettings.fogMode = FogMode.Linear;
        RenderSettings.fogColor = new Color(0.48f, 0.62f, 0.75f);
        RenderSettings.fogStartDistance = 50f;
        RenderSettings.fogEndDistance = 1000f;

        // Lens flare feel
        sun.flare = Resources.GetBuiltinResource<Flare>("50mmZoom.flare");

        // Terrain moisture = 0 → nothing needed in Unity

        Debug.Log("FF photo lighting applied!");
    }
}
