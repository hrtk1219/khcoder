package gui_window::morpho_detail;
use base qw(gui_window);
use strict;
use Tk;
use gui_window::morpho_check;
use mysql_morpho_check;


sub _new{
	my $self = shift;
	my $mw = $::main_gui->mw;
	my $bunhyojiwin = $::main_gui->mw->Toplevel;
	$bunhyojiwin->focus;
	my $msg = '形態素解析結果：詳細'; Jcode::convert(\$msg,'sjis','euc');
	$bunhyojiwin->title("$msg");

	$self->{list} = $bunhyojiwin->Scrolled(
		'HList',
		-scrollbars       => 'osoe',
		-header           => 1,
		-itemtype         => 'text',
		-font             => 'TKFN',
		-columns          => 6,
		-padx             => 2,
		-background       => 'white',
		-selectforeground => 'brown',
		-selectbackground => 'cyan',
		-selectmode       => 'extended',
		-height           => 20,
	)->pack(-fill =>'both',-expand => 'yes');
	
	$self->{list}->header('create',0,-text => Jcode->new('表層語')->sjis);
	$self->{list}->header('create',1,-text => Jcode->new('基本形')->sjis);
	$self->{list}->header('create',2,-text => Jcode->new('品詞')->sjis);
	$self->{list}->header('create',3,-text =>' ');
	$self->{list}->header('create',4,-text => Jcode->new('茶筌-品詞')->sjis);
	$self->{list}->header('create',5,-text => Jcode->new('茶筌-活用')->sjis);

	$self->{pre_btn} = $bunhyojiwin->Button(
		-text => Jcode->new('前の検索結果')->sjis,
		-font => "TKFN",
		-borderwidth => '1',
		-command => sub{ $mw->after(10,sub {
			my $n = $self->{parent}->prev;
			unless ($n > 0){return;}
			$self->_view($n);
		});} 
	)->pack(-side => 'left',-pady   => 1,);

	$self->{nxt_btn} = $bunhyojiwin->Button(
		-text => Jcode->new('次の検索結果')->sjis,
		-font => "TKFN",
		-borderwidth => '1',
		-command => sub{ $mw->after(10,sub {
			my $n = $self->{parent}->next;
			unless ($n > 0){return;}
			$self->_view($n);
		});} 
	)->pack(-side => 'left',-pady   => 1,);

	$bunhyojiwin->Button(
		-text => Jcode->new('コピー')->sjis,
		-font => "TKFN",
		-borderwidth => '1',
		-command => sub{ $mw->after(10,sub {gui_hlist->copy($self->list);});} 
	)->pack(-side => 'right',-pady   => 1,);

	$self->{win_obj} = $bunhyojiwin;
	return $self;
}

sub view{
	my $self = shift;
	my %args = @_;
	$self->{parent} = $args{parent};
	$self->_view($args{query});
}
sub _view{
	my $self = shift;
	my $n = shift;
	my $r = mysql_morpho_check->detail($n);
	
	$self->list->delete('all');
	my $row = 0;
	foreach my $i (@{$r}){
		$self->list->add($row,-at => "$row");
		$self->list->itemCreate($row,0,-text  => Jcode->new("$i->[0]")->sjis);
		if (length($i->[4]) > 1){
			$self->list->itemCreate($row,1,-text  => Jcode->new("$i->[1]")->sjis);
		}
		$self->list->itemCreate($row,2,-text  => Jcode->new("$i->[2]")->sjis);
		$self->list->itemCreate($row,4,-text  => Jcode->new("$i->[3]")->sjis);
		$self->list->itemCreate($row,5,-text  => Jcode->new("$i->[4]")->sjis);
		++$row;
	}
	$self->list->yview(0);
	$self->update_buttons;
}
sub update_buttons{
	my $self = shift;
	
	# 次の結果
	if ($self->{parent}->if_next){
		$self->{nxt_btn}->configure(-state, 'normal');
	} else {
		$self->{nxt_btn}->configure(-state, 'disable');
	}
	# 前の結果
	if ($self->{parent}->if_prev){
		$self->{pre_btn}->configure(-state, 'normal');
	} else {
		$self->{pre_btn}->configure(-state, 'disable');
	}
}



sub win_name{
	return 'w_morpho_detail';
}
sub list{
	my $self = shift;
	return $self->{list};
}
1;
