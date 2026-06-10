cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1276"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1276/agentshield_0.2.1276_darwin_amd64.tar.gz"
      sha256 "1f406b261cc267f8601c5d23691683775a3cbb8b1fc3e5923bccbb63dfe2e0d3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1276/agentshield_0.2.1276_darwin_arm64.tar.gz"
      sha256 "00ad2da993c7cc6cb8a1f19d945134ee380ea2006d0edd4bc84a43baf16d415b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1276/agentshield_0.2.1276_linux_amd64.tar.gz"
      sha256 "80bc58bb878b95a4d75db6e85fe7177b1de262f2503685019f24399cedaea3b7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1276/agentshield_0.2.1276_linux_arm64.tar.gz"
      sha256 "e3675189eceb2861f510137783e910303c4c500a7514760198f5a5666dbd0819"
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
