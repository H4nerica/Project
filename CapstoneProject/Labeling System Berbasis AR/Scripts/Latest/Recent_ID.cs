using UnityEngine;
using TMPro;

public class Recent_ID : MonoBehaviour
{
    [Header("Source")]
    public ItemInfoManager infoManager;

    [Header("Snapshot (runtime)")]
    [HideInInspector] public string recentID;
    public ItemData recentData;

    [Header("UI - Assign separately")]
    public TMP_Text idText1;   // first ID display
    public TMP_Text idText2;   // second ID display (duplicate)
    public TMP_Text nameText;
    public TMP_Text tagText;

    [Header("Expiry - Separate TMPs")]
    public TMP_Text expireDay;
    public TMP_Text expireMonth;
    public TMP_Text expireYear;

    private string lastSeenID;

    void Update()
    {
        if (string.IsNullOrEmpty(CurrentMarkerID.currentID))
            return;

        if (CurrentMarkerID.currentID == lastSeenID)
            return;

        lastSeenID = CurrentMarkerID.currentID;
        SaveFromCurrent();
        UpdateDisplay();
    }

    void SaveFromCurrent()
    {
        recentID = CurrentMarkerID.currentID;

        if (infoManager == null)
        {
            recentData = null;
            return;
        }

        ItemData data = infoManager.GetItemByID(recentID);
        if (data == null)
        {
            recentData = null;
            return;
        }

        recentData = new ItemData
        {
            id = data.id,
            name = data.name,
            expireIn = data.expireIn,
            tag = data.tag
        };

        Debug.Log("[Recent_ID] Updated automatically → " + recentID);
    }

    void UpdateDisplay()
    {
        if (recentData == null)
        {
            if (idText1 != null) idText1.text = "-";
            if (idText2 != null) idText2.text = "";
            if (nameText != null) nameText.text = "-";
            if (tagText != null) tagText.text = "-";
            if (expireDay != null) expireDay.text = "-";
            if (expireMonth != null) expireMonth.text = "-";
            if (expireYear != null) expireYear.text = "-";
            return;
        }

        // IDs
        if (idText1 != null) idText1.text = recentData.id;
        if (idText2 != null) idText2.text = string.IsNullOrEmpty(recentData.id) ? "" : recentData.id;

        if (nameText != null) nameText.text = recentData.name;
        if (tagText != null) tagText.text = recentData.tag;

        // Expiry split
        if (!string.IsNullOrEmpty(recentData.expireIn))
        {
            string[] parts = recentData.expireIn.Split('-'); // dd-MM-yyyy
            if (parts.Length == 3)
            {
                if (expireDay != null) expireDay.text = parts[0];
                if (expireMonth != null) expireMonth.text = parts[1];
                if (expireYear != null) expireYear.text = parts[2];
            }
        }
        else
        {
            if (expireDay != null) expireDay.text = "-";
            if (expireMonth != null) expireMonth.text = "-";
            if (expireYear != null) expireYear.text = "-";
        }
    }
}
