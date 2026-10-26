using UnityEngine;

public class ChangeAllMaterialsColor : MonoBehaviour
{
    void Start()
    {
        // Hex color #DEDEDE
        Color newColor = new Color32(0xDE, 0xDE, 0xDE, 255);

        // Scene ke saare Renderers find karo
        Renderer[] allRenderers = FindObjectsOfType<Renderer>();

        foreach (Renderer rend in allRenderers)
        {
            foreach (Material mat in rend.materials)
            {
                if (mat.HasProperty("_Color"))
                {
                    mat.color = newColor;
                }
            }
        }

        Debug.Log("All materials color changed to #DEDEDE");
    }
}
