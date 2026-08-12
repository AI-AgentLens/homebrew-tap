cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1826"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1826/agentshield_0.2.1826_darwin_amd64.tar.gz"
      sha256 "5ae1b851b7a919501283ea9aedf0a415960a4dfcda662d25b5195a96343fcc4a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1826/agentshield_0.2.1826_darwin_arm64.tar.gz"
      sha256 "91985e23c7a65635bb250432e1d25bf7e4eea49b244aca6b754e089b5c5b1269"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1826/agentshield_0.2.1826_linux_amd64.tar.gz"
      sha256 "7a39e58ef45639d8b78875089be11cd40d684dac3cb56f6baefb31a8300499c7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1826/agentshield_0.2.1826_linux_arm64.tar.gz"
      sha256 "97e5ecc09a30e8709b138c960667bfad2321d8e57048df6537a43b614f8051e0"
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
