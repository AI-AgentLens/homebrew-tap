cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.102"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.102/agentshield_0.2.102_darwin_amd64.tar.gz"
      sha256 "3347f4803161e4914a10a86cd120dcdbd6f7990d7f08b5ddbc68f3d75ed54cbc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.102/agentshield_0.2.102_darwin_arm64.tar.gz"
      sha256 "84e676d242dcde572bcd5fea76be3dc4322392503ad079e7a3d8f24d20872126"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.102/agentshield_0.2.102_linux_amd64.tar.gz"
      sha256 "6290ceeefde8a735be194d67ad44b039cf95e3e2eff59c868a1286be0192ed01"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.102/agentshield_0.2.102_linux_arm64.tar.gz"
      sha256 "14fcf480672be03a2743b9307ec4051f3923fd68d29d10dae77f716624640b1b"
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
