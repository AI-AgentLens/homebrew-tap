cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.354"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.354/agentshield_0.2.354_darwin_amd64.tar.gz"
      sha256 "59b8f7f5d89c7ef376aac81d4a9b1dfe454e6ed95461d76666aabe8f7de96887"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.354/agentshield_0.2.354_darwin_arm64.tar.gz"
      sha256 "3dd84a1df8f51b76cd1eb74a751d15cdfa2d1e6f040e4637924b5109f1e591dd"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.354/agentshield_0.2.354_linux_amd64.tar.gz"
      sha256 "0590402ed4a0d41d63083abbe807730187190856b079a550aa1eb381799d4775"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.354/agentshield_0.2.354_linux_arm64.tar.gz"
      sha256 "0113c671f1ada73183d0d0367175f5700cc59899b5918c926bb81d8fcefc9c59"
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
