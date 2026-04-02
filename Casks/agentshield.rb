cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.300"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.300/agentshield_0.2.300_darwin_amd64.tar.gz"
      sha256 "784bd1e8fcb67f85e0d50d6229519458568b348d4595e089fe0aa9ceccc376a8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.300/agentshield_0.2.300_darwin_arm64.tar.gz"
      sha256 "be0e7ca0c47724540a7e9d2f3858d689b553b8d0547c00257709bcb9875915e6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.300/agentshield_0.2.300_linux_amd64.tar.gz"
      sha256 "9cf57d15ac422907d89ecdf0207943685edd42724114dfb1b81228a6d0291153"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.300/agentshield_0.2.300_linux_arm64.tar.gz"
      sha256 "86b3b57a458b10b7762e059c6ad76a9d1e202385613fedfa7bf005b13179ad16"
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
