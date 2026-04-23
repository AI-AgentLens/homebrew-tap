cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.699"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.699/agentshield_0.2.699_darwin_amd64.tar.gz"
      sha256 "d46730a0867c9767846e13292027cb2bf6c238011d1b6b92b78fc8efcbd9f81f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.699/agentshield_0.2.699_darwin_arm64.tar.gz"
      sha256 "abfb0a154837c6b6d8df42db442cf5426fb19efeb361f9e8408d4934f669cf68"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.699/agentshield_0.2.699_linux_amd64.tar.gz"
      sha256 "b5cdb69cc81035a4211dac957ab3c455bfdf4aefea587f0444becb3890ce894b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.699/agentshield_0.2.699_linux_arm64.tar.gz"
      sha256 "2b3d67faaa4401d4f6dece221af144f6c7a0e714a1a5df8a8fb00681c4f21d1d"
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
