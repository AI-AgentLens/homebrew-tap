cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1801"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1801/agentshield_0.2.1801_darwin_amd64.tar.gz"
      sha256 "1e959521ef332feb42ab34d5badcddeac82aaa89b28e659a528f870e93fdc456"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1801/agentshield_0.2.1801_darwin_arm64.tar.gz"
      sha256 "0809028eb69e7b490b00143f9a9869ef8152f45b5bca23e50367123190ae8d9f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1801/agentshield_0.2.1801_linux_amd64.tar.gz"
      sha256 "3bb2dea1952804cd1dcab55a1b5f8e3c38273ecf83248a5680c7492fb85de577"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1801/agentshield_0.2.1801_linux_arm64.tar.gz"
      sha256 "6da4684bc79aa3504b3f24dddf6fa7ecf75c867b31729ba255294eb73e27f750"
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
