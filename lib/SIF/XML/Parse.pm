package SIF::XML::Parse;
use perl5i::2;
use XML::Simple;

=head1 NAME

SIF::XML::Parse - Parse all incoming XML matching SIF AU 1.3

=head1 SYNOPSIS

TODO

=head1 DESCRIPTION

Parse the standard SIF AU 1.3 inputs to a usable data structure. Normalised in
a format that can be used to store in our local database.

This module is really only a helper for demonstration code, testing and a
starting point to write fully featured systems. Parsing XML can be done using
objects mapped to the XSD.

=cut

# NOTE: student is SIF US 3.0, not AU 1.3 - here for testing only to match SIF-RS

# All singular types - for expanding to array
my @types = qw/
	student
	StudentPersonal
	SchoolInfo
	StaffInfo
	RoomInfo
	StaffAssignment
	StaffPersonal
	TeachingGroup
	TimeTable
	TimeTableCell
	TimeTableSubject
/;

# Simple collections - for dealing with one level collectings matching name
my $collections = {
	students => 'student',
	StudentPersonals => 'StudentPersonal',
	SchoolInfos => 'SchoolInfo',
	RoomInfos => 'RoomInfo',
	StaffPersonals => 'StaffPersonal',
};

# ------------------------------------------------------------------------------
# HELPERS
# ------------------------------------------------------------------------------

# Remove namespace - deep parse hash
sub normalise {
	my ($in) = @_;
	return if ( ref($in) ne 'HASH' );
	foreach my $key (keys %$in) {
		if ($key =~ /^.+:(.+)$/) {
			$in->{$1} = $in->{$key};
			delete $in->{$key};
			$key = $1;
		}
		normalise($in->{$key});
	}
}

sub flat {
	my ($in) = @_;
	return (ref($in) eq 'ARRAY') ? $in->[0] : $in;
}

# ------------------------------------------------------------------------------
# OBJECT = 'student(s)'
# ------------------------------------------------------------------------------

sub StudentPersonal {
	my ($class, $raw) = @_;
	$raw = flat($raw);
	return {
		RefId => $raw->{RefId},
		LocalId => $raw->{LocalId}{content},
		GivenName => $raw->{PersonInfo}{Name}{GivenName}{content},
		FamilyName => $raw->{PersonInfo}{Name}{FamilyName}{content},
	};
}

sub SchoolInfo {
	my ($class, $raw) = @_;
	$raw = flat($raw);
	return {
		RefId => $raw->{RefId},
		LocalId => $raw->{LocalId}{content},
		SchoolName => $raw->{SchoolName}{content},
	};
}

sub RoomInfo {
	my ($class, $raw) = @_;
	$raw = flat($raw);
	return {
		RefId => $raw->{RefId},
		RoomNumber => $raw->{RoomNumber}{content},
		Description => $raw->{Description}{content},
		Capacity => $raw->{Capacity}{content},
	};
}

sub StaffPersonal {
	my ($class, $raw) = @_;
	$raw = flat($raw);
	return {
		RefId => $raw->{RefId},
		RoomNumber => $raw->{RoomNumber}{content},
		Description => $raw->{Description}{content},
		Capacity => $raw->{Capacity}{content},
	};
}

sub TeachingGroup {
	my ($class, $raw) = @_;
	$raw = flat($raw);
	return {
		RefId => $raw->{RefId},
		SchoolYear => $raw->{SchoolYear}{content},
		SchoolInfo_RefId => $raw->{SchoolInfoRefId}{content},
		# ShortName, LongName ?
		# Arrays !
		#	StudentList / TeachingGroupStudent / StudentPersonalRefId	*
		#	TeacherList / TeachingGroupTeacher / StaffPersonalRefId	*
	};
}

sub TimeTableSubject {
	my ($class, $raw) = @_;
	$raw = flat($raw);
	return {
		RefId => $raw->{RefId},
		SubjectLocalId => $raw->{SubjectLocalId}{content},
		AcademicYear => $raw->{AcademicYear}{content},
		Faculty => $raw->{Faculty}{content},
		SubjectShortName => $raw->{SubjectShortName}{content},
		SubjectLongName => $raw->{SubjectLongName}{content},
		SubjectType => $raw->{SubjectType}{content},
		SchoolInfo_RefId => $raw->{SchoolInfoRefId}{content},
	};
}

sub TimeTableCell {
	my ($class, $raw) = @_;
	$raw = flat($raw);
	return {
		RefId => $raw->{RefId},
		TimeTable_RefId => $raw->{TimeTableRefId}{content},
		TimeTableSubject_RefId => $raw->{TimeTableSubjectRefId}{content},
		TeachingGroup_RefId => $raw->{TeachingGroupRefId}{content},
		RoomInfo_RefId => $raw->{RoomInfo}{content},
		CellType => $raw->{CellType}{content},
		PeriodId => $raw->{PeriodID}{content},
		DayId => $raw->{DayID}{content},
	};
}

sub TimeTable {
	my ($class, $raw, $xml) = @_;
	$raw = flat($raw);
	return {
		RefId => $raw->{RefId},
		SchoolInfo_RefId => $raw->{SchoolInfoRefId}{content},
		RAWDATA => $xml,
	};
}

# ------------------------------------------------------------------------------
# OBJECT = 'StudentPersonal(s)'
# ------------------------------------------------------------------------------
sub student {
	my ($class, $raw) = @_;
	$raw = flat($raw);
	return {
		RefId => $raw->{refId},
		LocalId => $raw->{localId}{content},
		GivenName => $raw->{name}{nameOfRecord}{givenName}{content},
		FamilyName => $raw->{name}{nameOfRecord}{familyName}{content},
	};
}

# ------------------------------------------------------------------------------
# Parse input
# ------------------------------------------------------------------------------
sub parse {
	my ($class, $xml) = @_;

	my $raw = XMLin($xml, 
		ForceArray => [@types],
		ForceContent => 1,
		KeepRoot => 1,
	);
	normalise($raw);

	my $sub = (keys %$raw)[0];

	my $out;
	if ($collections->{$sub}) {
		my $newsub = $collections->{$sub};
		$out = [
			map {
				SIF::XML::Parse->$newsub($_, $xml);
			} @{$raw->{$sub}{$newsub}}
		];
	}
	else {
		$out = SIF::XML::Parse->$sub($raw->{$sub}, $xml);
	}

	return {
		type => $sub,
		data => $out,
		xml => $xml,
	}
}

1;

