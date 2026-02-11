# Terms of Service Implementation - Complete Documentation

## Overview

Comprehensive Terms of Service (ToS) created for Aquarium Hobbyist app with full integration into the Flutter application.

**Date Created:** February 7, 2025  
**Status:** ✅ Complete - Ready for hosting

---

## What Was Created

### 1. Terms of Service Document
**File:** `/mnt/c/Users/larki/Documents/Aquarium App Dev/terms-of-service.md`

Comprehensive legal document covering:

✅ **License Grant** - Limited, non-commercial, personal use  
✅ **Educational Disclaimer** - Not professional/veterinary advice (highlighted)  
✅ **User Responsibilities** - Accurate data, animal welfare, prohibited conduct  
✅ **Data Ownership** - User owns all their data  
✅ **Local Storage** - Clarifies data stays on device  
✅ **No Warranty** - "AS IS" provision, no guarantees  
✅ **Limitation of Liability** - Protection from fish health/data loss claims  
✅ **Termination Rights** - Both user and developer  
✅ **Modifications** - Right to update app and terms  
✅ **Third-Party Content** - Disclaimers for species information  
✅ **Intellectual Property** - App ownership, user content ownership  
✅ **Privacy Reference** - Links to Privacy Policy  
✅ **Governing Law** - UK jurisdiction  
✅ **Contact Information** - Support email and developer name  
✅ **Summary Section** - User-friendly TL;DR at the end

**Word Count:** ~3,500 words  
**Reading Time:** ~15 minutes  
**Legal Tone:** Standard app ToS, protective but readable

### 2. Terms of Service Screen (Flutter)
**File:** `/mnt/c/Users/larki/Documents/Aquarium App Dev/repo/apps/aquarium_app/lib/screens/terms_of_service_screen.dart`

Features:
- ✅ Clean, scrollable summary view with key sections
- ✅ Icon-based cards for each major topic
- ✅ Highlighted warning for "Educational Use Only" (orange)
- ✅ "View Full Terms" button (opens hosted URL)
- ✅ "Contact Us" button (shows contact dialog)
- ✅ Last updated date display
- ✅ Acceptance notice at bottom
- ✅ Matches app's design theme (AppColors, AppTypography)
- ✅ Graceful error handling if URL can't launch

**Sections Displayed:**
1. Educational Use Only ⚠️ (highlighted)
2. No Warranties
3. Your Data
4. License
5. Changes

### 3. AboutScreen Integration
**File:** `/mnt/c/Users/larki/Documents/Aquarium App Dev/repo/apps/aquarium_app/lib/screens/about_screen.dart`

Changes made:
- ✅ Added import for `terms_of_service_screen.dart`
- ✅ Added "Terms" button next to "Privacy" and "Licenses"
- ✅ Button uses gavel icon (⚖️) for legal recognition
- ✅ Navigation to TermsOfServiceScreen on tap
- ✅ Changed Row to Wrap for better responsive layout

---

## How It Works

### User Flow
1. User opens **About** screen from app drawer/settings
2. Sees three buttons: **Privacy** | **Terms** | **Licenses**
3. Taps **Terms** → Opens **TermsOfServiceScreen**
4. Reads summary of key points in-app
5. (Optional) Taps **"View Full Terms"** → Opens hosted URL in browser
6. (Optional) Taps **"Contact Us"** → Shows email and developer info

### Technical Integration
```dart
// AboutScreen navigation
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const TermsOfServiceScreen(),
  ),
);

// TermsOfServiceScreen opens hosted URL
final Uri url = Uri.parse('https://aquariumhobbyist.app/terms-of-service');
await launchUrl(url, mode: LaunchMode.externalApplication);
```

---

## Hosting Instructions

### Required: Host the Terms of Service Online

The app expects the full terms to be available at:
```
https://aquariumhobbyist.app/terms-of-service
```

**⚠️ UPDATE THIS URL** in `terms_of_service_screen.dart` line ~184:
```dart
final Uri url = Uri.parse('https://YOUR-ACTUAL-DOMAIN.com/terms-of-service');
```

### Recommended Hosting Options

#### Option 1: GitHub Pages (Free, Simple)
Perfect if you already have the privacy policy there.

**Steps:**
1. Create a GitHub repo (e.g., `aquarium-app-legal`)
2. Add `terms-of-service.md` to the repo
3. Enable GitHub Pages in repo settings
4. Access at: `https://yourusername.github.io/aquarium-app-legal/terms-of-service`

**Convert Markdown to HTML:**
```bash
# Install pandoc if needed
# brew install pandoc (macOS)
# sudo apt install pandoc (Linux)

pandoc terms-of-service.md -o terms-of-service.html --standalone --css=style.css
```

#### Option 2: Google Play Store Console
If you're distributing via Play Store, you can host it there.

**Steps:**
1. Go to Google Play Console → Your App
2. Navigate to **Store Presence** → **App Content**
3. Add "Terms of Service" URL in privacy policy section
4. Upload the markdown as HTML

#### Option 3: Simple Static Site (Netlify, Vercel, etc.)
Free hosting with automatic HTTPS.

**Netlify Drop:**
1. Convert `terms-of-service.md` to HTML
2. Create `index.html` that links to it
3. Drag folder to Netlify Drop
4. Get instant URL: `https://your-app-name.netlify.app/terms-of-service.html`

#### Option 4: Custom Domain
If you have `aquariumhobbyist.app`:
1. Create `/terms-of-service.html` or `/terms-of-service/` route
2. Upload the HTML version
3. Ensure HTTPS is enabled
4. Test the URL before releasing the app

### Hosting Checklist
- [ ] Convert markdown to HTML (or use GitHub's markdown rendering)
- [ ] Upload to hosting platform
- [ ] Verify URL is publicly accessible
- [ ] Test HTTPS works (required for `url_launcher`)
- [ ] Update URL in `terms_of_service_screen.dart`
- [ ] Test "View Full Terms" button in app
- [ ] (Optional) Add same hosting for Privacy Policy for consistency

---

## Files Modified/Created Summary

| File | Status | Purpose |
|------|--------|---------|
| `terms-of-service.md` | ✅ Created | Legal document (host this online) |
| `lib/screens/terms_of_service_screen.dart` | ✅ Created | In-app summary + link to full terms |
| `lib/screens/about_screen.dart` | ✅ Modified | Added "Terms" button |
| `TERMS_OF_SERVICE_IMPLEMENTATION.md` | ✅ Created | This documentation file |

---

## Testing Checklist

Before releasing:

### In-App Testing
- [ ] "Terms" button appears on About screen
- [ ] Tapping "Terms" opens TermsOfServiceScreen
- [ ] All sections display correctly
- [ ] Icons render properly
- [ ] Educational disclaimer is highlighted (orange)
- [ ] "Contact Us" dialog shows correct email
- [ ] "View Full Terms" button is tappable

### Hosted URL Testing
- [ ] Full terms are accessible online
- [ ] URL loads over HTTPS
- [ ] Markdown renders properly (if using GitHub)
- [ ] Mobile-friendly layout
- [ ] URL is updated in code (not placeholder)
- [ ] "View Full Terms" opens the browser correctly
- [ ] Browser shows the full document

### Legal Review (Recommended)
- [ ] Have a lawyer review the terms (especially limitation of liability)
- [ ] Verify UK law governing clause is appropriate for your jurisdiction
- [ ] Confirm educational disclaimer is sufficient for your use case
- [ ] Check age requirement (currently 13+) matches your target audience

---

## Maintenance

### When to Update Terms
- Major app changes (e.g., adding in-app purchases)
- New features that affect user data
- Changes in applicable laws
- User-generated content features
- Third-party integrations

### How to Update
1. Edit `terms-of-service.md`
2. Update "Last Updated" date at top
3. Update date in `terms_of_service_screen.dart` (line ~148)
4. Re-upload to hosting platform
5. (Optional) Show in-app notification about changes
6. Consider adding version history at bottom of document

---

## Legal Notes (Disclaimer)

⚠️ **I am an AI, not a lawyer.** This ToS is a template based on common app terms.

**You should:**
- ✅ Have a qualified lawyer review these terms
- ✅ Customize for your specific jurisdiction and use case
- ✅ Update contact information (currently: support@aquariumhobbyist.app)
- ✅ Verify the limitation of liability is enforceable in your region
- ✅ Consider age restrictions (currently 13+)

**Key legal protections included:**
- Educational disclaimer (not professional advice)
- No warranty for fish health/welfare
- Limitation of liability for data loss
- User responsibility for animal care
- Right to modify/terminate service

---

## Next Steps

1. **Choose hosting platform** (GitHub Pages recommended for simplicity)
2. **Convert markdown to HTML** (if needed)
3. **Upload and get public URL**
4. **Update `terms_of_service_screen.dart`** with real URL
5. **Test the flow** end-to-end
6. **(Optional) Legal review** before Play Store submission
7. **Match hosting with Privacy Policy** (use same platform)

---

## Contact Information in Terms

Currently set to:
- **Email:** support@aquariumhobbyist.app
- **Developer:** Tiarnan Larkin

**⚠️ Update these** if you want different contact details:
- In `terms-of-service.md` (bottom of document)
- In `terms_of_service_screen.dart` (_showContactInfo method)

---

## Comparison with Privacy Policy

Both documents are now in sync:

| Aspect | Privacy Policy | Terms of Service |
|--------|----------------|------------------|
| **Location** | privacy-policy.md | terms-of-service.md |
| **Screen** | privacy_policy_screen.dart | terms_of_service_screen.dart |
| **Linked from** | About screen | About screen |
| **Hosting** | Needs URL | Needs URL (same place) |
| **Last Updated** | Feb 6, 2025 | Feb 7, 2025 |
| **Style** | User-friendly, transparent | Legal, protective |

**Recommendation:** Host both documents on the same platform for consistency.

---

## Questions?

If you need to modify the terms, common changes:

**Add in-app purchases:**
- Add section 16: "Purchases and Payments"
- Include refund policy, pricing disclaimers

**Add user accounts/cloud sync:**
- Update "Your Data" section
- Modify Privacy Policy too
- Add account termination clause

**Add user-generated public content:**
- Add "Content License" section
- Include takedown policy
- Add moderation rights

**Change jurisdiction:**
- Update section 14 (Governing Law)
- Might need different disclaimer language

---

## Summary

✅ **Complete Terms of Service** drafted with all required protections  
✅ **In-app screen** created with clean summary view  
✅ **About screen** updated with navigation link  
✅ **Hosting ready** - just needs URL configuration  
✅ **Documentation** provided for maintenance and updates  

**Status:** Ready for hosting and deployment. Update the URL, test the flow, and you're good to go! 🚀

---

**Created by:** Claude (Subagent)  
**Date:** February 7, 2025  
**For:** Aquarium Hobbyist Android App v1.0
