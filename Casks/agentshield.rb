cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.422"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.422/agentshield_0.2.422_darwin_amd64.tar.gz"
      sha256 "8c715c6112f6001cd7c9f06a9b541e1c833ce6f996ecd6f7c4d007d28a66f61f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.422/agentshield_0.2.422_darwin_arm64.tar.gz"
      sha256 "f23934d688847f63cc091e4cef8c15d9a753f766ec92d6e6a97a2bad1712ecc0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.422/agentshield_0.2.422_linux_amd64.tar.gz"
      sha256 "6bdd3fda3fe70791819785c77bd3bc67a3de25e1b4ee3478724fa8eee57fdcec"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.422/agentshield_0.2.422_linux_arm64.tar.gz"
      sha256 "79a22425331f6972afa305df0060e903c2df141c4080f9a6a1f2cadd0437cf9e"
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
