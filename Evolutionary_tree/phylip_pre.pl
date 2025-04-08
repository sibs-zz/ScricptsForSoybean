use strict;
##$ARGV[0]=id
##$ARGV[1]=dis/mdist
open INPUT1,"<",$ARGV[0] or die "Can't open INPUT1:$!\n";
my @array1;
my $id;
my @array2;
my $nn=0;
while(<INPUT1>){
        chomp;
        $id=(split/\t/,$_)[0];
        if($id=~/\./){
          $id=~s/\.\S+//;
        }
        $array2[$nn]=$id;
  $nn++;
}
my $line=$nn;
print " $line\n";
close INPUT1;
  
open INPUT2,"<",$ARGV[1] or die "Can't open INPUT2:$!\n";
my $ll=0;
my @array3;
my $align;
while(<INPUT2>){
        chomp;
        @array1=split/\t/,$_;
        @array3=split//,$array2[$ll];
        $align=15-$#array3;
        print "$array2[$ll]"." " x $align;
        
        for(0..$#array1){
          printf "%1.4f ",$array1[$_];
        }
        print "\n";
        $ll++;
}
