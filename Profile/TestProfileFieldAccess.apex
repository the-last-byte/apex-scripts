//Usage example:
/*
testFieldAccess(
	[
		SELECT Name
		FROM Profile
		WHERE ** My Criteria **
	],
	new Set<String> {
		'Case.Some_Read_Only_Field__c',
		'Account.Some_Read_Only_Field__c'
	},
	new Set<String> {
		'Case.Some_Edit_Field__c',
		'Account.Some_Edit_Field__c'
	}
};

Run in under anonymous apex and check debug logs.  Filter by debug
to see output.
*/

private static Boolean profileShouldHaveEditAccess(String profileName) {
	//Return TRUE OR FALSE here
	//Perhaps only licences that end with "- Admin" should have edit access?
	//If so, this is the place.  Return FALSE for readonly, and TRUE for edit.
	return true;
}

public static void testFieldAccess(List<Profile> profilesToTest, Set<String> readAccessFields, Set<String> editAccessFields) {
	List<PermissionSet> permissionSets = [
		SELECT ProfileId, Profile.Name,
		(
			SELECT Field, PermissionsEdit,
				PermissionsRead
			FROM FieldPerms
			WHERE (
				Field IN :readAccessFields
				OR Field IN :editAccessFields
			)
		)
		FROM PermissionSet
		WHERE ProfileId IN :profilesToTest
		AND IsOwnedByProfile = TRUE
	];
	System.assertEquals(profilesToTest.size(), permissionSets.size());


	for(PermissionSet ps : permissionSets) {
		final Boolean hasEditAccess = profileShouldHaveEditAccess(ps.Profile.Name);
		System.debug('Testing ' + ps.Profile.Name + ' has ' + (hasEditAccess ? 'Edit' : 'Read') + ' access');

		Map<String, FieldPermissions> fieldToPermission = mapPermissionsToFields(ps);

		FieldPermissions tempPermission;
		for(String fieldName : readAccessFields) {
			tempPermission = fieldToPermission.get(fieldName);
			final String status;
			if(tempPermission == null) status = 'NOT FOUND';
			else if(!tempPermission.PermissionsRead) status = 'ERROR';
			else status = 'OK';

			System.debug('- - - ' + fieldName + ' - Read: ' + status);
		}

		if(hasEditAccess) {
			for(String fieldName : editAccessFields) {
				tempPermission = fieldToPermission.get(fieldName);
				final String status;
				if(tempPermission == null) status = 'NOT FOUND';
				else if(!tempPermission.PermissionsEdit) status = 'ERROR';
				else status = 'OK';

				System.debug('- - - ' + fieldName + ' - Edit: ' + status);
			}
		}

	}
}

private static Map<String, FieldPermissions> mapPermissionsToFields(PermissionSet ps) {
	Map<String, FieldPermissions> fieldToPermission = new Map<String, FieldPermissions>();
	for(FieldPermissions fp : ps.FieldPerms) {
		fieldToPermission.put(fp.Field, fp);
	}
	return fieldToPermission;
}


   