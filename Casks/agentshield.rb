cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1752"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1752/agentshield_0.2.1752_darwin_amd64.tar.gz"
      sha256 "19d8c46d90ee489b447712b6c64fd4be7dc7c48e157e477233a4c8db1c2c9f2c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1752/agentshield_0.2.1752_darwin_arm64.tar.gz"
      sha256 "abf9d40a747a0834c8ede305635f1bcdf8605a34c13962773a63cdeab11d4d7c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1752/agentshield_0.2.1752_linux_amd64.tar.gz"
      sha256 "19d91c52022a29345dd64c61a00c755898826cdb06b5064f47904ee4761e8419"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1752/agentshield_0.2.1752_linux_arm64.tar.gz"
      sha256 "d62603d32c5a580142144434de9d2b3477f6b8de207716d1d8071e17526f49b6"
    end
  end

  # Stop the heartbeat daemon before upgrading so the old binary doesn't keep
  # running as a zombie after brew replaces it.
  preflight do
    if OS.mac?
      plist = File.expand_path("~/Library/LaunchAgents/com.aiagentlens.agentshield.plist")
      if File.exist?(plist)
        system_command "/bin/launchctl", args: ["bootout", "gui/#{Process.uid}/com.aiagentlens.agentshield"], print_stderr: false
        File.delete(plist) if File.exist?(plist)
      end
    end
  end

  postflight do
    if OS.mac?
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentshield"]
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentcompliance"]
    end
  end

  uninstall launchctl: "com.aiagentlens.agentshield",
            delete:    "~/Library/LaunchAgents/com.aiagentlens.agentshield.plist"

  caveats <<~EOS
    Two tools installed:
      agentshield      — Runtime security gateway for AI agents
      agentcompliance  — Local compliance scanner (semgrep-based)

    Quick start:
      agentshield setup
      agentshield login
  EOS
end
