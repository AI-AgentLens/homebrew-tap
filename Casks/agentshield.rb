cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1626"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1626/agentshield_0.2.1626_darwin_amd64.tar.gz"
      sha256 "a829162df7639789bfa672fbe1a9b63cd3bf262b7bfeac5806a7922e354cb72b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1626/agentshield_0.2.1626_darwin_arm64.tar.gz"
      sha256 "38f301527d1463ad19df771f05446e48c2a41be4b4827b4b16571b268f9c54a1"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1626/agentshield_0.2.1626_linux_amd64.tar.gz"
      sha256 "8cc03058e19a1418bb104592114e5fc6e5844fa46587553c2ac8daa6d4ba17ce"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1626/agentshield_0.2.1626_linux_arm64.tar.gz"
      sha256 "94c44976dbb9bfa87d972dfdcab1be3731ec16d9468e994fe4b33e43d9745c70"
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
