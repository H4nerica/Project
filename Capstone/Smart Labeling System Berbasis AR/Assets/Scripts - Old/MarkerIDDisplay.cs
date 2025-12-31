using UnityEngine;
using TMPro;

public class MarkerIDDisplay : MonoBehaviour
{
    public TextMeshProUGUI idText;

    void Update()
    {
        idText.text = CurrentMarkerID.currentID;
    }
}
