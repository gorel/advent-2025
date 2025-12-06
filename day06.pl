use strict;
use warnings;

my @lines;

while (<>) {
  chomp;
  next unless /\S/;
  push @lines, $_;
}
my @char_lines = map { [ split // ] } @lines;

my $ops_line = pop @lines;
my @col_starts;
for (my $i = 0; $i < length $ops_line; $i++) {
  my $ch = substr($ops_line, $i, 1);
  push @col_starts, $i if $ch =~ /\S/;
}
my @ops = map { substr($ops_line, $_, 1) } @col_starts;

my $lastend = -1;
my (@raw, @nums1, @nums2);
for my $line (@lines) {
  my @chars = split //, $line;
  my @vals = $line =~ /\S+/g;
  push @raw, \@vals;
  my $len = length $line;
  $lastend = $len if $len > $lastend;
}

@nums1 = map {
  my $col = $_;
  [ map { $_->[$col] } @raw ]
} 0 .. $#{$raw[0]};

for my $ci (0 .. $#col_starts) {
  my @row;
  my $start = $col_starts[$ci];
  my $end = ($ci < $#col_starts) ? $col_starts[$ci + 1] : $lastend;
  # Go columnwise from start to end
  for my $i ($start .. $end - 1) {
    my $transposed = '';
    # For each line, construct the transposed number
    for my $line_idx (0 .. $#char_lines) {
      my @chars = @{$char_lines[$line_idx]};
      my $ch = $chars[$i] // ' ';
      if ($ch =~ /\d/) {
        $transposed .= $ch;
      }
    }
    push @row, $transposed if $transposed ne '';
  }
  push @nums2, \@row;
}

sub my_eval {
  my ($op, $nums) = @_;
  my $result = shift @$nums;
  for my $n (@$nums) {
    if ($op eq '+') {
      $result += $n;
    } elsif ($op eq '*') {
      $result *= $n;
    }
  }
  return $result;
}

my ($part1, $part2) = (0, 0);
for my $i (0 .. $#nums1) {
  my $vals = $nums1[$i];
  my $vals2 = $nums2[$i];
  my $op = $ops[$i];

  $part1 += my_eval($op, [@$vals]);
  $part2 += my_eval($op, [@$vals2]);
}

print $part1, "\n";
print $part2, "\n";
