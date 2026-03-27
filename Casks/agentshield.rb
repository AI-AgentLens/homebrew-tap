cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.116"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.116/agentshield_0.2.116_darwin_amd64.tar.gz"
      sha256 "9334fc0282fb7c77881cd9e70dbfea00c0769aa80c1ebeb34073930862951104"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.116/agentshield_0.2.116_darwin_arm64.tar.gz"
      sha256 "a4b336011e8e5e24a5649826eb64db8d6e8a9aecac5ca6ad5a617e2bac6abd18"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.116/agentshield_0.2.116_linux_amd64.tar.gz"
      sha256 "faac23489791072de38e25e0051881682afc3b600b10ed0efbf961fd02a2dc37"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.116/agentshield_0.2.116_linux_arm64.tar.gz"
      sha256 "97ffc110700c64283b59ad4782101d7a22f916d75f534749a85ed9efc79af71a"
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
