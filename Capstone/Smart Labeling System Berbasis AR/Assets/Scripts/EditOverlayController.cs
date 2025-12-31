using UnityEngine;
using UnityEngine.UI;

[RequireComponent(typeof(Button))]
public class EditOverlayController : MonoBehaviour
{
    void Awake()
    {
        // Ambil component Button di object ini
        Button btn = GetComponent<Button>();
        if (btn != null)
        {
            // Tambahkan listener QuitApp otomatis
            btn.onClick.AddListener(QuitApp);
        }
        else
        {
            Debug.LogWarning("[ExitButtonController] Button component missing!");
        }
    }

    void QuitApp()
    {
        Application.Quit();

#if UNITY_EDITOR
        UnityEditor.EditorApplication.isPlaying = false;
#endif
    }
}
