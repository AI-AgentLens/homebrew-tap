cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1973"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1973/agentshield_0.2.1973_darwin_amd64.tar.gz"
      sha256 "cd9190be2389a7f0ae11c3ed001f8c7f53cbf9f7cc0d837b7aa82151df7d52bf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1973/agentshield_0.2.1973_darwin_arm64.tar.gz"
      sha256 "107a0c3ce59c0acaba62dfd00c802fa6905b4280a2b3f14558496c614f644425"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1973/agentshield_0.2.1973_linux_amd64.tar.gz"
      sha256 "93615cf5a81597fa924298c757952bd3e68bbbb7984aed607aee8fcc9502e939"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1973/agentshield_0.2.1973_linux_arm64.tar.gz"
      sha256 "f1d21cc8cc3385f71f79d74096ba891ef2606d706ea1e9efb1e8ede3891d92c3"
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
