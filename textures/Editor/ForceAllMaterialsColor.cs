using UnityEngine;
using UnityEditor;

public class ForceAllMaterialsColor
{
    [MenuItem("Tools/Set All Materials To CCCCCC")]
    static void ChangeAllMaterials()
    {
        string[] materialGuids = AssetDatabase.FindAssets("t:Material");

        // Hex color #CCCCCC
        Color newColor = new Color32(0xCC, 0xCC, 0xCC, 255);

        int changedCount = 0;

        foreach (string guid in materialGuids)
        {
            string path = AssetDatabase.GUIDToAssetPath(guid);
            Material mat = AssetDatabase.LoadAssetAtPath<Material>(path);

            if (mat != null)
            {
                if (mat.HasProperty("_Color"))
                    mat.SetColor("_Color", newColor);

                if (mat.HasProperty("_BaseColor"))
                    mat.SetColor("_BaseColor", newColor);

                EditorUtility.SetDirty(mat);
                changedCount++;
            }
        }

        AssetDatabase.SaveAssets();
        Debug.Log("Total Materials Changed To #CCCCCC: " + changedCount);
    }
}
