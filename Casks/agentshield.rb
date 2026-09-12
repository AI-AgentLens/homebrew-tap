cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2126"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2126/agentshield_0.2.2126_darwin_amd64.tar.gz"
      sha256 "462f956dee188d899e8d0db1673362bd0868d98035f76ddaaa594837c06c3470"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2126/agentshield_0.2.2126_darwin_arm64.tar.gz"
      sha256 "90b6c9b66494671695f24733cddaeced3c72284ddba0fd74927e3691a6394c08"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2126/agentshield_0.2.2126_linux_amd64.tar.gz"
      sha256 "7282ee1e19518d0dceb69974e67937496abb3aea38c21af9739911cdfa789229"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2126/agentshield_0.2.2126_linux_arm64.tar.gz"
      sha256 "c01aecc07bc96200ed8240259a6eb7b2546e45e44d5c24846bfce19c8429c34e"
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
