<?php
namespace app\command;

use app\model\Bind;
use think\console\Command;
use think\console\Input;
use think\console\input\Option;
use think\console\Output;

class SyncRoleBindings extends Command
{
    protected function configure()
    {
        $this->setName('bind:sync-missing')
            ->addOption('limit', 'l', Option::VALUE_OPTIONAL, '单次最大回填数量（默认 200，最大 1000）', 200)
            ->setDescription('手工回填缺失的 user_bind 绑定关系');
    }

    protected function execute(Input $input, Output $output)
    {
        $limit = intval($input->getOption('limit'));
        if ($limit <= 0) {
            $limit = 200;
        }
        if ($limit > 1000) {
            $limit = 1000;
        }

        $bind = new Bind();
        try {
            $result = $bind->syncMissingRoleBindings($limit);
            $output->writeln('sync result: ' . json_encode($result, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES));
            return 0;
        } catch (\Throwable $e) {
            $output->writeln('<error>sync failed: ' . $e->getMessage() . '</error>');
            return 1;
        }
    }
}
