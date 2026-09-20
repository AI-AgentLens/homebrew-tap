cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2201"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2201/agentshield_0.2.2201_darwin_amd64.tar.gz"
      sha256 "31cf0306b512d24e804f9b32884bb55434168540de18c407d9877bd87556d8a7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2201/agentshield_0.2.2201_darwin_arm64.tar.gz"
      sha256 "c1ccd8c99a207e13cb435b3772ca25eba321b9c5393b3dff43da431a806755b7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2201/agentshield_0.2.2201_linux_amd64.tar.gz"
      sha256 "0d5c0e84412c6c6cf25a82af624f741463d071ccf1b2abc20ce8f70f7bfec993"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2201/agentshield_0.2.2201_linux_arm64.tar.gz"
      sha256 "5005d46c143dcaee8012855ea3db374aab9a62a1f4b4056c34ea844f61ecf7d3"
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
