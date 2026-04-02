cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.317"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.317/agentshield_0.2.317_darwin_amd64.tar.gz"
      sha256 "e057c9b4766e8cd8bd222a94c40a58690c1fa26b29bfeaef3d4deabb7e04f6cf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.317/agentshield_0.2.317_darwin_arm64.tar.gz"
      sha256 "341208a16d97beb3382289a066e3d04965eeec1fe0670c41065a3e3d93855013"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.317/agentshield_0.2.317_linux_amd64.tar.gz"
      sha256 "de3e6a38d97ffea1c0df49d6032d0fa962cc14dd75dcdd7ab229b61a4d1d71eb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.317/agentshield_0.2.317_linux_arm64.tar.gz"
      sha256 "dbdda5e509d1de985993a7af49fd74bd320576dbc11abab756f9cb599ae9749e"
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
