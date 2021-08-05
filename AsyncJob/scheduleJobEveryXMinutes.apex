public static void unscheduleJobPrefix(final String jobPrefix) {
	for(CronTrigger job : [
		SELECT Id
		FROM CronTrigger
		WHERE CronJobDetail.Name LIKE :(jobPrefix + '%')
	]) {
		System.abortJob(job.Id);
	}
}

public static void scheduleJobEveryNMinutes(final String jobPrefix, final Integer minutesInTheHour, final Schedulable jobToRun) {
	unscheduleJobPrefix(jobPrefix);
	for (Integer i = 0; i < 60; i = i + minutesInTheHour) {
		String cExpression = 0 + ' ' + String.valueOf(i) + ' ' + '*' + ' ' + '*' + ' ' + '*' + ' ' + '?' + ' ' + '*' ;	
		System.schedule(jobPrefix + ' ' + i, cExpression, jobToRun);
	}
}