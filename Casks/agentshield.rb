cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.444"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.444/agentshield_0.2.444_darwin_amd64.tar.gz"
      sha256 "143fb21848248c50e1d265476409524dea09e225da0da325055cc5c24ec622ba"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.444/agentshield_0.2.444_darwin_arm64.tar.gz"
      sha256 "ce354fb2094c356bff823d0278df4654f6d94802bc4c708a01408340b777c081"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.444/agentshield_0.2.444_linux_amd64.tar.gz"
      sha256 "e17ffc74a6a0419d48845ed63410301833fc952c7cd455dfccbe352e25f7b758"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.444/agentshield_0.2.444_linux_arm64.tar.gz"
      sha256 "94152b537259aef464304797d46bdeb6e5a106d84299a0b91001cc66ed866a0f"
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
