cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1041"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1041/agentshield_0.2.1041_darwin_amd64.tar.gz"
      sha256 "5c4870f7e5b83b6f9b78605c0389b664834c0d2938fc4805192c46bb301a2b77"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1041/agentshield_0.2.1041_darwin_arm64.tar.gz"
      sha256 "52e4d11dac5223760154034423ea2de9481f9158a2112fc9fcbe0dd427c547b1"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1041/agentshield_0.2.1041_linux_amd64.tar.gz"
      sha256 "c3c5d3f9f988ae43a5dd125d628fb25c8b1660480ef3a20283b321a35a0358f9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1041/agentshield_0.2.1041_linux_arm64.tar.gz"
      sha256 "7822b94911337c48e8b4f7c65a1103a8be2b8db675672cbe95050fd6074215a7"
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
